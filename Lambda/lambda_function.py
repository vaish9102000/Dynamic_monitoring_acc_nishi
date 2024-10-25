import boto3
import os
import logging
 
# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)
 
cloudwatch_client = boto3.client('cloudwatch')
 
# Define the services and their metrics with warning and critical thresholds
AWS_METRICS = [
    # EC2 Metrics
    {
        "Service": "EC2",
        "MetricName": "CPUUtilization",
        "Namespace": "AWS/EC2",
        "DimensionName": "InstanceId",
        "WarningThreshold": 85.0,
        "CriticalThreshold": 90.0,
        "Statistic": "Maximum"
    },
    {
        "Service": "EC2",
        "MetricName": "StatusCheckFailed_Instance",
        "Namespace": "AWS/EC2",
        "DimensionName": "InstanceId",
        "WarningThreshold": 1.0,
        "Statistic": "Maximum"
    },
    {
        "Service": "EC2",
        "MetricName": "SStatusCheckFailed_System",
        "Namespace": "AWS/EC2",
        "DimensionName": "InstanceId",
        "WarningThreshold": 1.0,
        "Statistic": "Ma"
    },
    # # EBS Metrics
    # {
    #     "Service": "EBS",
    #     "MetricName": "VolumeWriteOps",
    #     "Namespace": "AWS/EBS",
    #     "DimensionName": "VolumeId",
    #     "WarningThreshold": 1000.0,
    #     "CriticalThreshold": 5000.0,
    #     "Statistic": "Sum"
    # },
    # {
    #     "Service": "EBS",
    #     "MetricName": "VolumeReadOps",
    #     "Namespace": "AWS/EBS",
    #     "DimensionName": "VolumeId",
    #     "WarningThreshold": 1000.0,
    #     "CriticalThreshold": 5000.0,
    #     "Statistic": "Sum"
    # },
    # # Lambda Metrics
    # {
    #     "Service": "Lambda",
    #     "MetricName": "Invocations",
    #     "Namespace": "AWS/Lambda",
    #     "DimensionName": "FunctionName",
    #     "WarningThreshold": 100.0,
    #     "CriticalThreshold": 500.0,
    #     "Statistic": "Sum"
    # },
    # {
    #     "Service": "Lambda",
    #     "MetricName": "Errors",
    #     "Namespace": "AWS/Lambda",
    #     "DimensionName": "FunctionName",
    #     "WarningThreshold": 1.0,
    #     "CriticalThreshold": 10.0,
    #     "Statistic": "Sum"
    # },
    # # RDS Metrics
    # {
    #     "Service": "RDS",
    #     "MetricName": "CPUUtilization",
    #     "Namespace": "AWS/RDS",
    #     "DimensionName": "DBInstanceIdentifier",
    #     "WarningThreshold": 70.0,
    #     "CriticalThreshold": 90.0,
    #     "Statistic": "Average"
    # },
    # {
    #     "Service": "RDS",
    #     "MetricName": "DatabaseConnections",
    #     "Namespace": "AWS/RDS",
    #     "DimensionName": "DBInstanceIdentifier",
    #     "WarningThreshold": 50.0,
    #     "CriticalThreshold": 100.0,
    #     "Statistic": "Average"
    # }
]
 
def lambda_handler(event, context):
    """
    Main Lambda handler function to create and delete alarms based on service metrics.
    """
    for metric in AWS_METRICS:
        try:
            resources = get_resources_from_cloudwatch(metric['Namespace'], metric['MetricName'], metric['DimensionName'])
            for resource in resources:
                # Create alarms for both Warning and Critical thresholds
                manage_alarm(resource, metric, 'Warning')
                manage_alarm(resource, metric, 'Critical')
 
            # Check and delete alarms for removed resources
            manage_deleted_resources(metric)
        except Exception as e:
            logger.error(f"Error processing {metric['Service']}: {e}")
 
    return {
        'statusCode': 200,
        'body': 'Alarms created or deleted for services'
    }
 
def get_resources_from_cloudwatch(namespace, metric_name, dimension_name):
    """
    Retrieve resources (e.g., EC2, EBS, Lambda, RDS) from CloudWatch that are reporting metrics.
    """
    resource_ids = set()
    paginator = cloudwatch_client.get_paginator('list_metrics')
    response_iterator = paginator.paginate(Namespace=namespace, MetricName=metric_name)
 
    for response in response_iterator:
        for metric in response['Metrics']:
            for dimension in metric['Dimensions']:
                if dimension['Name'] == dimension_name:
                    resource_ids.add(dimension['Value'])
 
    return list(resource_ids)
 
def manage_alarm(resource, metric, alarm_type):
    """
    Create or update alarms based on the threshold type (Warning or Critical).
    """
    threshold = metric['WarningThreshold'] if alarm_type == 'Warning' else metric['CriticalThreshold']
    alarm_name = f'{resource}-{metric["MetricName"]}-{metric["Service"]}-{alarm_type}'
    
    if not alarm_exists(alarm_name):
        create_alarm(resource, metric, threshold, alarm_name, alarm_type)
 
def alarm_exists(alarm_name):
    """
    Check if a CloudWatch alarm with the given name already exists.
    """
    response = cloudwatch_client.describe_alarms(AlarmNames=[alarm_name])
    return len(response['MetricAlarms']) > 0
 
def create_alarm(resource, metric, threshold, alarm_name, alarm_type):
    """
    Create a CloudWatch alarm for the given resource and metric with the specified threshold.
    """
    try:
        cloudwatch_client.put_metric_alarm(
            AlarmName=alarm_name,
            AlarmDescription=f'{alarm_type} alarm for {metric["MetricName"]} on {metric["Service"]} resource {resource}',
            ActionsEnabled=True,
            MetricName=metric['MetricName'],
            Namespace=metric['Namespace'],
            Statistic=metric['Statistic'],
            Dimensions=[{'Name': metric['DimensionName'], 'Value': resource}],
            Period=300,  # 5 minutes
            EvaluationPeriods=1,
            Threshold=threshold,
            ComparisonOperator='GreaterThanThreshold',
            AlarmActions=[os.environ.get('SNS_TOPIC_ARN')],
            TreatMissingData='missing'
        )
        logger.info(f'Created {alarm_type} alarm {alarm_name} for {metric["Service"]} resource {resource}')
    except Exception as e:
        logger.error(f"Error creating alarm {alarm_name}: {e}")
 
def manage_deleted_resources(metric):
    """
    Identify deleted resources and remove their corresponding alarms.
    """
    existing_alarms = get_existing_alarms(metric['MetricName'], metric['Service'])
    for alarm in existing_alarms:
        resource_id = extract_resource_id_from_alarm_name(alarm['AlarmName'])
        if not resource_still_exists(resource_id, metric['Namespace'], metric['DimensionName']):
            delete_alarm(alarm['AlarmName'])
 
def get_existing_alarms(metric_name, service):
    """
    Get all alarms associated with a specific metric and service.
    """
    paginator = cloudwatch_client.get_paginator('describe_alarms')
    response_iterator = paginator.paginate(AlarmNamePrefix=f'{service}-{metric_name}')
    alarms = []
 
    for response in response_iterator:
        alarms.extend(response['MetricAlarms'])
    
    return alarms
 
def extract_resource_id_from_alarm_name(alarm_name):
    """
    Extract the resource ID (e.g., InstanceId, VolumeId) from the alarm name.
    """
    return alarm_name.split('-')[0]
 
def resource_still_exists(resource_id, namespace, dimension_name):
    """
    Check if the resource is still reporting metrics to CloudWatch.
    """
    try:
        response = cloudwatch_client.list_metrics(
            Namespace=namespace,
            Dimensions=[{'Name': dimension_name, 'Value': resource_id}]
        )
        return len(response['Metrics']) > 0
    except Exception:
        return False
 
def delete_alarm(alarm_name):
    """
    Delete a CloudWatch alarm with the specified name.
    """
    try:
        cloudwatch_client.delete_alarms(AlarmNames=[alarm_name])
        logger.info(f'Deleted alarm {alarm_name}')
    except Exception as e:
        logger.error(f"Error deleting alarm {alarm_name}: {e}")
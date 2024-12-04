# utility/connection.py
from google.cloud import secretmanager

def get_secret(project_id,secret_id,version):
    """
    Retrieve a specific version of a secret from Google Cloud Secret Manager.

    Args:
        project_id (str): The ID of the Google Cloud project containing the secret.
        secret_id (str): The ID or name of the secret to retrieve.
        version (str): The version of the secret to access.

    Returns:
        str: The decoded secret value as a string.
    """

    # Construct the secret resource name
    client = secretmanager.SecretManagerServiceClient()
    # Form the full resource name for the secret version
    secret_resource_name = f"projects/{project_id}/secrets/{secret_id}/versions/{version}"
    # Access the secret
    response = client.access_secret_version(name=secret_resource_name)
    # Extract the secret value (payload)
    secret_value = response.payload.data.decode("utf-8")
    return secret_value


def get_connection_string(project_id,connection_details):
    """
    Generate a database connection string based on provided details.

    Args:
        project_id (str): The ID of the Google Cloud project, used to retrieve secret information.
        connection_details (dict): Dictionary containing connection details like driver, server, database, and other configuration.

    Returns:
        str: A formatted connection string to connect to a database.
    """
    if "username" not in connection_details or connection_details['username'] == "":
        connection_string = f"Driver={connection_details['driver']};Server={connection_details['server']};Database={connection_details['database']};Trusted_Connection={connection_details['trusted_connection']};Encrypt={connection_details['encrypt']};"
    else:
        connection_password = get_secret(project_id,connection_details['password_secret_id'],connection_details['secret_version'])
        connection_string = f"Driver={connection_details['driver']};Server={connection_details['server']};Database={connection_details['database']};UID={connection_details['username']};PWD={connection_password};Encrypt={connection_details['encrypt']};"
    return connection_string

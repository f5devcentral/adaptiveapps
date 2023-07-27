'''A sample script to convert an F5 BIG-IP AWAF policy to F5 Distributed Cloud resources'''

import argparse
import io
import json
import re
import zipfile

import requests


def convert_policy(api_key, workspace, payload):
    '''Use policysupervisor.io API to convert AWAF policy to Distributed Cloud payloads'''
    print('Uploading policy to policysupervisor.io')
    req = requests.post(
        'https://policysupervisor.io/api/v1/conversion/AWAF/XC',
        headers={
            'X-Workspace-Key': workspace,
            'X-API-Key': api_key
        },
        json={ 'policy': payload }
    )

    if req.status_code != 200:
        raise ValueError(f'Failed to convert policy ({req.status_code}): {req.text}')

    firewall = {}
    service_policy = {}

    print('Extracting results from policysupervisor.io')
    with io.BytesIO(req.content) as zip_bytes:
        with zipfile.ZipFile(zip_bytes) as zip_file:
            filenames = zip_file.namelist()
            def extract(name_re):
                name = next(filter(re.compile(name_re).match, filenames))
                file = zip_file.read(name)
                return json.loads(file)
            firewall = extract('.*ApplicationFirewall.json')
            service_policy = extract('.*ServicePolicy-01.json')

    return {
        'firewall': firewall,
        'service_policy': service_policy,
    }


def create_update_resource(api_token, tenant, namespace, resource, payload):
    '''Generic method to create or update a resource on F5 Distributed Cloud'''
    volterra_url = f'https://{tenant}.console.ves.volterra.io/api/config/namespaces/{namespace}'
    name = payload['metadata']['name']
    print(f'Creating XC {resource} resource named {name}')
    req = requests.post(
        f'{volterra_url}/{resource}',
        headers={
            'Authorization': f'APIToken {api_token}'
        },
        json=payload
    )
    if req.status_code == 409:
        print(f'An XC {resource} resource named {name} already exists, updating instead')
        req = requests.put(
            f'{volterra_url}/{resource}/{name}',
            headers={
                'Authorization': f'APIToken {api_token}'
            },
            json=payload
        )

    if req.status_code != 200:
        raise ValueError(
            f'Failed to create XC {resource} resource named {name} ({req.status_code}): {req.text}'
        )


def create_firewall(api_token, tenant, namespace, payload):
    '''Create or update the application firewall on F5 Distributed Cloud'''
    create_update_resource(api_token, tenant, namespace, 'app_firewalls', payload)


def create_service_policy(api_token, tenant, namespace, payload):
    '''Create or update the service policy on F5 Distributed Cloud'''
    create_update_resource(api_token, tenant, namespace, 'service_policys', payload)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('filename')
    parser.add_argument('--ps-workspace', help='The policysupervisor.io workspace')
    parser.add_argument('--ps-api-key', help='The policysupervisor.io API key')
    parser.add_argument('--xc-tenant', help='The Distributed Cloud tenant to deploy objects to')
    parser.add_argument('--xc-namespace', help='The Distributed Cloud namespace to deploy objects to')
    parser.add_argument('--xc-api-token', help='The Distributed Cloud API token to use for authorization')
    args = parser.parse_args()

    ps_workspace = args.ps_workspace or os.environ['PS_WORKSPACE']
    ps_api_key = args.ps_api_key or os.environ['PS_API_KEY']
    xc_api_token = args.xc_api_token or os.environ['XC_API_TOKEN']
    xc_tenant = args.xc_tenant or os.environ['XC_TENANT']
    xc_namespace = args.xc_namespace or os.environ['XC_NAMESPACE']

    with open(args.filename, 'r', encoding='utf8') as fin:
        results = convert_policy(ps_api_key, ps_workspace, fin.read())
    create_firewall(xc_api_token, xc_tenant, xc_namespace, results['firewall'])
    create_service_policy(xc_api_token, xc_tenant, xc_namespace, results['service_policy'])

main()

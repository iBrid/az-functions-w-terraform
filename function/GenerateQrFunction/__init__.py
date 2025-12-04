import os
import io
import uuid
import json

import qrcode
from azure.storage.blob import BlobServiceClient, ContentSettings
import azure.functions as func


def main(req: func.HttpRequest) -> func.HttpResponse:
    try:
        req_body = req.get_json(silent=True) or {}
    except Exception:
        req_body = {}

    url = req.params.get('url') or req_body.get('url')
    if not url:
        return func.HttpResponse(json.dumps({"error": "Missing 'url' parameter"}), status_code=400, mimetype="application/json")

    # Generate QR code image
    qr = qrcode.QRCode(error_correction=qrcode.constants.ERROR_CORRECT_M)
    qr.add_data(url)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")

    buf = io.BytesIO()
    img.save(buf, format="PNG")
    buf.seek(0)

    # Upload to Blob Storage
    conn_str = os.getenv('AZURE_STORAGE_CONNECTION_STRING') or os.getenv('AzureWebJobsStorage')
    container = os.getenv('QR_CONTAINER') or os.getenv('STORAGE_CONTAINER') or 'qrcodes'
    if not conn_str:
        return func.HttpResponse(json.dumps({"error": "Missing storage connection string in 'AZURE_STORAGE_CONNECTION_STRING' app setting"}), status_code=500, mimetype="application/json")

    blob_name = f"qr-{uuid.uuid4().hex}.png"
    bsc = BlobServiceClient.from_connection_string(conn_str)
    container_client = bsc.get_container_client(container)

    try:
        container_client.create_container()
    except Exception:
        # container may already exist or creation may not be allowed from function identity; ignore
        pass

    blob_client = container_client.get_blob_client(blob_name)
    content_settings = ContentSettings(content_type='image/png')
    blob_client.upload_blob(buf.getvalue(), overwrite=True, content_settings=content_settings)

    return func.HttpResponse(json.dumps({"blob_name": blob_name, "blob_url": blob_client.url}), status_code=200, mimetype="application/json")

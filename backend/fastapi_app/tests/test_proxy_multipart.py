import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from api.v1.endpoints.proxy import router


@pytest.fixture
def client(monkeypatch):
    app = FastAPI()
    app.include_router(router, prefix="/api")

    class FakeAsyncClient:
        async def request(self, **kwargs):
            return type(
                "Response",
                (),
                {
                    "status_code": 200,
                    "headers": {},
                    "content": b'{"ok": true}',
                    "text": '{"ok": true}',
                },
            )()

    monkeypatch.setattr("api.v1.endpoints.proxy.get_http_client", lambda: FakeAsyncClient())
    return TestClient(app)


def test_proxy_forwards_multipart_body(client):
    response = client.post(
        "/api/products/farmer/products/",
        files={"image": ("img.png", b"image-data", "image/png")},
        data={"name": "Tomatoes", "price_per_unit": "120"},
    )

    assert response.status_code == 200

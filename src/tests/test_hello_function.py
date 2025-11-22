"""Tests for Azure Function HTTP triggers."""

import json

import azure.functions as func


def test_hello_function_with_name():
    """Test hello function with name parameter."""
    # Import the function
    from function_app import hello_world

    # Create a mock request with name parameter
    req = func.HttpRequest(
        method="GET", body=b"", url="/api/hello", params={"name": "TestUser"}
    )  # noqa: E501

    # Call the function
    response = hello_world(req)

    # Assert response
    assert response.status_code == 200
    assert "Hello, TestUser" in response.get_body().decode()


def test_hello_function_without_name():
    """Test hello function without name parameter."""
    from function_app import hello_world

    # Create a mock request without name parameter
    req = func.HttpRequest(method="GET", body=b"", url="/api/hello", params={})

    # Call the function
    response = hello_world(req)

    # Assert response
    assert response.status_code == 200
    assert "Hello" in response.get_body().decode()


def test_hello_function_with_body():
    """Test hello function with name in body."""
    from function_app import hello_world

    # Create a mock request with name in body
    body_data = json.dumps({"name": "BodyUser"})
    req = func.HttpRequest(
        method="POST",
        body=body_data.encode("utf-8"),
        url="/api/hello",
        params={},
    )

    # Call the function
    response = hello_world(req)

    # Assert response
    assert response.status_code == 200
    assert "Hello, BodyUser" in response.get_body().decode()

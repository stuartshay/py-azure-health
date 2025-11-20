import logging

import azure.functions as func

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)


@app.route(route="hello")
def hello_world(req: func.HttpRequest) -> func.HttpResponse:
    """
    HTTP trigger function that returns a simple Hello World message.

    Args:
        req: The HTTP request object

    Returns:
        HTTP response with Hello World message
    """
    logging.info("Python HTTP trigger function processed a request.")

    name = req.params.get("name")
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get("name")

    if name:
        return func.HttpResponse(
            f"Hello, {name}! This HTTP triggered function executed successfully.",
            status_code=200,
        )
    else:
        return func.HttpResponse(
            "Hello World! This HTTP triggered function executed "
            "successfully. Pass a name in the query string or in the "
            "request body for a personalized response.",
            status_code=200,
        )

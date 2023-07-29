"""ミドルウェア用のモジュール"""
import datetime
from json import JSONDecodeError, loads
from logging import getLogger

from rest_framework import status

from application.utils.logs import LoggerName

application_logger = getLogger(LoggerName.APPLICATION.value)
emergency_logger = getLogger(LoggerName.EMERGENCY.value)


class LoggingMiddleware:
    """APIの開始と終了をロギングするミドルウェア"""

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # API呼び出し以外はログに出さない
        if request.path.endswith(".js") or request.path in (
            # Swaggerのパス
            "/api/docs/",
            "/api/schema/",
        ):
            return self.get_response(request)

        method = request.method
        ip = get_client_ip(request)
        path = request.path

        user = request.user
        user_info = "未ログイン"
        if user.is_authenticated:
            user_info = f"{user.employee_number} {user.username}"

        start_time = datetime.datetime.now()
        response = self.get_response(request)
        status_code = response.status_code
        end_time = datetime.datetime.now()
        duration_time = end_time - start_time
        message = f"{ip} {user_info} {method} {path} 実行時間: {duration_time} {status_code} "
        if status.is_success(response.status_code):
            application_logger.info(message)
        elif status.is_client_error(response.status_code):
            application_logger.warning(
                f"{message}\n{response.content.decode()}"
            )
        elif status.is_server_error(response.status_code):
            error_msg = response.content.decode().split("Request")[0]
            emergency_logger.error(f"{message}\n{error_msg}")
        else:
            application_logger.warning(message)
        return response


def get_client_ip(request):
    """クライアントのIPアドレスを取得"""
    x_forwarded_for = request.META.get("HTTP_X_FORWARDED_FOR")
    if x_forwarded_for:
        ip = x_forwarded_for.split(",")[0]
    else:
        ip = request.META.get("REMOTE_ADDR")
    return ip

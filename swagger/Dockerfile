FROM swaggerapi/swagger-ui

# Swagger JSONをコピー
COPY swagger.json /usr/share/nginx/html/swagger.json

# 環境変数でSwagger JSONのエンドポイントを設定
ENV SWAGGER_JSON=/usr/share/nginx/html/swagger.json
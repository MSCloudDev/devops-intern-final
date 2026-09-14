FROM nginx:1.27-alpine

ARG BUILD_SHA=unknown

COPY index.html /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf

RUN sed -i "s|BUILD_SHA_PLACEHOLDER|${BUILD_SHA}|g" /usr/share/nginx/html/index.html \
    && chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /etc/nginx \
    && touch /tmp/nginx.pid \
    && chown nginx:nginx /tmp/nginx.pid

EXPOSE 8080

USER nginx

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -q -O - http://127.0.0.1:8080/healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]
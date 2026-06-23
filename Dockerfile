# Сборка сайта
FROM hugomods/hugo:exts-non-root as builder
WORKDIR /src
COPY site/ /src
RUN hugo --minify

# Продакшн-веб-сервер
FROM nginx:alpine
COPY --from=builder /src/public /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

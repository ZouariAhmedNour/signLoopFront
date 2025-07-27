# Étape 1 : Utiliser Flutter stable
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY . .

# Construire pour le web
RUN flutter build web --release

# Étape 2 : Nginx pour servir les fichiers web + proxy
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Nettoyer et copier les fichiers Flutter
RUN rm -rf ./*
COPY --from=build /app/build/web .

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

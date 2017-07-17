# Bobababes in Prod

The only dependency we need is docker and docker-compose installed on a linux
box and the DNS for boba-babes pointing to the IP address.

### If it's they very first time deploy

If it's the first time deploying, we need to do some things before starting the
app. We'll only need to do this once ever.

```bash
# Create the volumes where certificates will persist. They need to persist
# forever so we can kill the containers without worring about losing them.
docker volume create --name certs
docker volume create --name certs-data

# Initialize the certificates from https://certbot.eff.org/ (EFF!).
docker run -it --rm \
	-v bobababes_certs:/etc/letsencrypt \
  -v bobababes_certs-data:/data/letsencrypt \
	deliverous/certbot \
	certonly --webroot --webroot-path=/data/letsencrypt -d boba-babes.com

# Good to go.
```

# Typical deployments

Stackahoy can automate this for you.

```bash
# Build the images for bobababes.
docker-compose -p bobababes build

# Stand up the containers.
docker-compose -p bobababes up -d
```

# SSL Certs

We can setup a cronjob to do this for us every 80 days.

```bash
# Renew tokens... when ssl expires.
docker run -t --rm \
	--volumes-from bobababes_proxy_1 \
	deliverous/certbot \
	renew \
	--webroot --webroot-path=/data/letsencrypt
```

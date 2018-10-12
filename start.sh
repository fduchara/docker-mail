docker run -ti --rm --name testmail --env-file .env -p 25:25 -p 587:587 -p 143:143 -v $PWD/mail:/home/vmail local/mail

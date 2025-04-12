echo This script generates a hashed password using bcrypt
@echo off
node -e "require('bcrypt').hash(process.argv[1], 10).then(hash => console.log('Senha criptografada:', hash))" %0
This assumes you have docker ready to go

```
cd /into/this/directory

# build the fir-lamdera:dev image
./deploy/build.sh

# run bash inside a container
./deploy/bash.sh

# ^ use the above to add elm deps

# For normal dev, just do
docker-compose dev up
```

Enjoy!

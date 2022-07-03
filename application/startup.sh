
echo 'Hey!'

if [ "$DB_SNAPSHOT" = "none" ] ; then rails db:create ; fi
if [ "$DB_SNAPSHOT" = "none" ] ; then rails db:schema:load ; fi
if [ "$DB_SNAPSHOT" = "none" ] ; then rails db:seed ; fi

# Build the assets
rails assets:precompile

# Startup the puma application server
puma -C config/application.rb -p 80

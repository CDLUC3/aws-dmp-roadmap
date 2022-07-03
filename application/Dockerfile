FROM ruby:2.7

RUN echo $(apt-cache search magick)

# Install packages
RUN apt-get clean
RUN apt-get update -qq && apt-get install -y build-essential libgmp3-dev libpq-dev vim git \
                                             apt-transport-https curl software-properties-common \
                                             imagemagick default-mysql-client

# Add the nodejs repository to apt-get
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash
RUN apt-get install -y nodejs
RUN apt-get update

# Env variables for application
ENV DB_ADAPTER=mysql2

# Adding project files
COPY roadmap .

# Ensure its using the timezone we want
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set the default editor for the generation of rails credentials
RUN touch ~/.bashrc
RUN echo "export EDITOR=vim" >> ~/.bashrc

# Install Bundler
RUN gem install bundler
RUN bundle config set without 'pgsql thin rollbar'
RUN mkdir pid

# Load dependencies
RUN bundle install --jobs 20 --retry 5

# Install and run Yarn
RUN npm install -g yarn
RUN yarn install

# Copy the custom config files for Docker
COPY overrides/config/database.yml config/database.yml
COPY overrides/config/webpacker.yml config/webpacker.yml
COPY overrides/config/environments/ci.rb config/environments/ci.rb
COPY overrides/config/initializers/dragonfly.rb config/initializers/dragonfly.rb
COPY overrides/config/initializers/wicked_pdf.rb config/initializers/wicked_pdf.rb
COPY overrides/config/webpack/ci.js config/webpack/ci.js

# Initialize the credentials file
RUN EDITOR='echo "$(cat config/credentials.yml.example)" >' bin/rails credentials:edit

# SETUP ENV variables
RUN export WICKED_PDF_PATH=`which wkhtmltopdf`

# Copy the startup script into the container
COPY --chown=755 overrides/docker-startup.rb ./docker-startup.rb

# expose correct port
EXPOSE 80 443 3306

CMD ["ruby", "docker-startup.rb"]
# CMD ["puma", "-C", "./config/application.rb", "-p", "80"]
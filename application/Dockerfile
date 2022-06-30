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
# && apt-get install -y yarn

# Env variables for application
ENV DB_ADAPTER=mysql2

# ARG INSTALL_PATH=/usr/src/app
# ENV INSTALL_PATH=$INSTALL_PATH
# ENV BUNDLE_PATH=/bundle/ \
#     BUNDLE_BIN=/bundle/bin \
#     GEM_HOME=/bundle
# ENV Path="${BUNDLE_BIN}:${PATH}"

# WORKDIR $INSTALL_PATH

# Adding gems
# COPY roadmap/Gemfile Gemfile
# COPY roadmap/Gemfile.lock Gemfile.lock
# COPY roadmap/package.json package.json
# COPY roadmap/yarn.lock yarn.lock

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

# Initialize config files and then build the credentials file
RUN cp config/database.yml.sample config/database.yml
RUN cp config/initializers/contact_us.rb.example config/initializers/contact_us.rb
RUN cp config/initializers/wicked_pdf.rb.example config/initializers/wicked_pdf.rb
RUN EDITOR='echo "$(cat config/credentials.yml.example)" >' bin/rails credentials:edit

# SETUP ENV variables
RUN export WICKED_PDF_PATH=`which wkhtmltopdf`

# Precompile the assets if the DB_NAME is present
RUN if ["$DB_NAME"] ; then $INSTALL_PATH/bin/rails assets:precompile ; fi

# expose correct port
EXPOSE 80 443

CMD ["echo", "HELLO"]

# CMD ["bin/puma", "-C", "config/application.rb", "-p", "3000"]

# Don't bother with the Command here, the AWS ECS orchestration passes this command when deploying
# CMD ["bundle", "exec", "puma", "-C", "config/application.rb", "-p", "8086"]
# CMD ["echo", "'It worked!'"]
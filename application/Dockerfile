FROM ruby:2.7

RUN echo $(apt-cache search magick)

# Dependancies
RUN apt-get clean
RUN apt-get update -qq && apt-get install -y build-essential libgmp3-dev libpq-dev vim git \
                                             imagemagick default-mysql-client

ARG INSTALL_PATH=/usr/src/app
ENV INSTALL_PATH=$INSTALL_PATH
WORKDIR $INSTALL_PATH

# Adding gems
COPY roadmap/Gemfile Gemfile
COPY roadmap/Gemfile.lock Gemfile.lock
COPY roadmap/package.json package.json
COPY roadmap/yarn.lock yarn.lock

RUN gem install bundler
RUN bundle config set without 'pgsql thin rollbar'
RUN bundle install --jobs 20 --retry 5
RUN mkdir pid

# Adding project files
COPY roadmap .

# Env variables for application
ENV DB_ADAPTER=mysql2
ENV RAILS_ENV=test

RUN touch ~/.bashrc
RUN echo "export EDITOR=vim" >> ~/.bashrc

# Install Node and Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g yarn
RUN yarn install

# Install yarn and wkhtmltopdf from package
# RUN wget --quiet https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.3/wkhtmltox-0.12.3_linux-generic-amd64.tar.xz && \
#     tar vxf wkhtmltox-0.12.3_linux-generic-amd64.tar.xz && \
#     cp wkhtmltox/bin/wk* /usr/local/bin/ && \
#     rm -rf wkhtmltox

# Chrome for chromedriver tests
# RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
# RUN dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install

# Initialize config files and then build the credentials file
RUN cp $INSTALL_PATH/config/database.yml.sample $INSTALL_PATH/config/database.yml
RUN cp $INSTALL_PATH/config/initializers/contact_us.rb.example $INSTALL_PATH/config/initializers/contact_us.rb
RUN cp $INSTALL_PATH/config/initializers/wicked_pdf.rb.example $INSTALL_PATH/config/initializers/wicked_pdf.rb
RUN cd $INSTALL_PATH && EDITOR='echo "$(cat config/credentials.yml.example)" >' bin/rails credentials:edit

# Install Bundler and Gem dependencies
# RUN cd $INSTALL_PATH && bin/rails assets:precompile && bin/rails dev:cache

# SETUP ENV variables
RUN export WICKED_PDF_PATH=`which wkhtmltopdf`

# expose correct port
EXPOSE 3000 8086 1234

# Ensure its using the timezone we want
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN echo Docker Build `date` > .version

CMD ["bundle", "exec", "puma", "-C", "config/application.rb", "-p", "8086"]

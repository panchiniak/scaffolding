# Intro

This is a live test folder.

Use:
cucumber --guess --format html -o ../tests/projects/sesi/results/resutls.html features/drupal_login.feature PROJECT_NAME="sesi" HIPCHAT_TOKEN="0fa67c1f429f478e49baa8a4d199ad" HIPCHAT_ROOM="Cucumber" FULLSHOT=true BASE_URL="http://dev-vs.dropit.in/" HTML_RESULTS_URL="http://dev-intelbras.dropit.in/sites/default/files/tests/results.html";

cucumber -p fullshot-ci --guess --format html -o ../tests/projects/sesi/results/results.html features/drupal_login.feature PROJECT_NAME="sesi" HIPCHAT_TOKEN="0fa67c1f429f478e49baa8a4d199ad" HIPCHAT_ROOM="Cucumber" FULLSHOT=true BASE_URL="http://dev-vs.dropit.in/" HTML_RESULTS_URL="http://dev-intelbras.dropit.in/sites/default/files/tests/results.html";

Use CUCUMBER_SYNC_SWITCH for switching syncronization of features as follows. Ir is required for running tests on threads. 

sudo cucumber -p fullshot-ci --guess --format html -o ../tests/projects/sesi/results/results.html features/drupal_login.feature PROJECT_NAME="sesi" HIPCHAT_TOKEN="0fa67c1f429f478e49baa8a4d199ad" HIPCHAT_ROOM="Cucumber" FULLSHOT=true BASE_URL="http://dev-vs.dropit.in/" HTML_RESULTS_URL="http://dev-intelbras.dropit.in/sites/default/files/tests/results.html" CUCUMBER_SYNC_SWITCH=false;

# Requirements

* RVM on Mac OSX / Linux
* Pik/JRuby/Bundler/Wac on Windows 

# Installation and Usage

1. Follow instructions at http://drupaldeelite.com.br/blog/teste-de-regressao-para-drupal
1. Run 'cucumber BASE_URL="http://your.url.and.ending.slash/"

# Mac OSX / Linux

1. ensure you have RVM (Ruby Version Manager) installed: http://rvm.beginrescueend.com/
2. $ bundle
3. $ bundle exec rake

# Windows

1. Install Ruby, Pik, Bundler and Wac (see my blog post: http://wp.me/p98zF-ca)
2. Make sure you 'pik' Ruby
3. $ bundle
4. $ bundle exec rake

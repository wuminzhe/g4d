# hello_rails7_pg_redis

A template to create a rails 7 dev container.

0. create a repo from this template.
1. clone the repo to your local
2. start a dev container for your local repo.

   I tried 1. vscode, 2. neovim + [nvim-dev-container](https://github.com/esensar/nvim-dev-container). both are ok.
   
4. In your dev container

   1. (optional) `service start cron` if you need crontab to work.

   2. Generate your rails project in the dev container.

      ```bash
      # importmaps + propshaft (my prefer) 
      rails new . -a propshaft -d=postgresql

      # or, one of the following
      # importmaps + sprockets
      rails new . -d=postgresql

      # importmaps + sprockets + tailwind, https://techracho.bpsinc.jp/hachi8833/2022_02_17/115435
      rails new . --css tailwind -d=postgresql

      # importmaps + propshaft + tailwind
      rails new . --css tailwind -a propshaft -d=postgresql

      # (nodejs) esbuild + sprockets + tailwind(my prefer)
      rails new . --javascript esbuild --css tailwind -d=postgresql

      # (nodejs) esbuild + propshaft + bootstrap
      rails new . --javascript esbuild --css bootstrap -a propshaft -d=postgresql
      ```

   3. fix config/database.yml by adding the `host`, `username` and `password` to the development section.

      ```yaml
      ...
      default: &default
         ...
         host: <%= ENV.fetch("POSTGRES_HOST") { "db" } %>
         username: <%= ENV.fetch("POSTGRES_USERNAME") { "postgres" } %>
         password: <%= ENV.fetch("POSTGRES_PASSWORD") { "password" } %>
      ...
      ```

      ```bash
      bundle exec rails db:create
      ```

   4. run your app in the container.

      ```bash

      ./bin/rails s

      # OR in nodejs build mode
      ./bin/dev
      ```

5. http://127.0.0.1:3000

6. database admin ui

  - pgadmin4: http://127.0.0.1:5050  
  - redisinsight: http://127.0.0.1:8001

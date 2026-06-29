apps:
  - name: aidatpanel-admin
    script: src/app.js
    cwd: ./adminpanel
    instances: 1
    exec_mode: fork
    env:
      NODE_ENV: production
      ADMIN_PORT: 4300
      ADMIN_API_BASE: https://api.aidatpanel.com/api/v1/admin

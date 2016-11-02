# Nagios Core
Nagios Core를 Container 형태로 배포하기 위해 만들었습니다.

##### - 사용법
```sh
[root@ruo91 ~]# docker build --rm -t nagios:core https://github.com/ruo91/docker-nagios-core.git
[root@ruo91 ~]# docker run -d --name="nagios-core" -h "nagios-core" \
-p 80:80 -p 443:443 nagios:core
```

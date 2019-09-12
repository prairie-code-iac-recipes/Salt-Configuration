docker-repo:
  pkgrepo.managed:
    - humanname: Official Docker Repository
    - baseurl: https://download.docker.com/linux/centos/7/x86_64/stable/
    - gpgkey: https://download.docker.com/linux/centos/gpg

python:
  pkg.installed:
    - names:
      - python
      - python2-pip

install_awscli:
  pip.installed:
    - name: awscli
    - upgrade: True

yum-utils:
  pkg:
    - installed

device-mapper-persistent-data:
  pkg:
    - installed

lvm2:
  pkg:
    - installed

nfs-utils:
  pkg:
    - installed

docker-ce:
  pkg:
    - installed

add-user-to-group:
  cmd.run:
    - name: usermod -a -G docker packer
    - runas: root

root-ecs-creds-refresh:
  cron.present:
    - user: root
    - name: eval $(aws ecr get-login --region us-east-1 --no-include-email)
    - hour: 0

packer-ecs-creds-refresh:
  cron.present:
    - user: packer
    - name: eval $(aws ecr get-login --region us-east-1 --no-include-email)
    - hour: 0

root-ecs-creds-init:
  cmd.run:
    - name: eval $(aws ecr get-login --region us-east-1 --no-include-email)
    - runas: root

packer-ecs-creds-init:
  cmd.run:
    - name: eval $(aws ecr get-login --region us-east-1 --no-include-email)
    - runas: packer

/usr/lib/systemd/system/docker.service:
  file.managed:
    - source: salt://docker-package/docker.service
    - user: root
    - group: root
    - mode: 644

docker:
  service.running:
    - enable: true
    - watch:
      - pkg: docker-ce

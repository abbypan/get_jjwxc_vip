# get_jjwxc_vip
将jjwxc账号上已购买的VIP文章存为本地TXT

# 安装

以debian环境为例

    $ apt-get install curl firefox
    $ cpanm -n Novel::Robot::Packer
    $ cpanm -n Encode::Locale

# 用法

    $ perl get_jjwxc_vip.pl [cookie_file/cookie_string] [novelid] [max_no_vip_chapter_num] [max_vip_chapter_num]

按 作者-书名.txt 格式保存，以 微笑的猫《墙头马上》为例:
    
    $ perl get_jjwxc_vip.pl ~/.mozilla/firefox/a1xxxxxx.default/cookies.sqlite 217747 20 41 | tee sample.log

下载日志参考 [sample.log](sample.log)

![sample](sample.png)

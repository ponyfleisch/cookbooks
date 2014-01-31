default['typo3']['root'] = node['apache']['docroot_dir']
default['typo3']['version'] = '6.1.5'
default['typo3']['file'] = "http://prdownloads.sourceforge.net/typo3/typo3_src-#{node['typo3']['version']}.tar.gz?download"
default['typo3']['dbname'] = 'typo3'
default['typo3']['dbuser'] = 'typo3'
default['typo3']['dbpasswd'] = 'typo3password'
default['typo3']['dumpfile'] = '/vagrant/dump.sql'
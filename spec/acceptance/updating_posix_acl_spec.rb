# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'updating posix_acls' do
  context 'on a simple acl with an additional user' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        include posix_acl::requirements
        user { ['blub', 'blub2']:
          ensure => 'present',
        }
        posix_acl { '/opt/test3':
          action     => exact,
          permission => [
            'user::rwx',
            'group::rwx',
            'mask::rwx',
            'other::---',
            'user:blub:r-x',
          ],
          provider   => posixacl,
          recursive  => false,
          require => User['blub'],
        }
        # we declare the file resource after posix_acl to verfiy autorequire work
        file { '/opt/test3':
          ensure => directory,
          owner  => root,
          group  => root,
          mode   => '2770',
        }
        PUPPET
      end
    end
  end

  context 'on adding ACLs without overwriting existing ACLs' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        include posix_acl::requirements
        user { ['blub', 'blub2']:
          ensure => 'present',
        }
        posix_acl { '/opt/test3':
          action     => set,
          permission => [
            'user::rwx',
            'group::rwx',
            'mask::rwx',
            'other::---',
            'user:blub2:r-x',
          ],
          provider   => posixacl,
          recursive  => false,
          require => User['blub2'],
        }
        # we declare the file resource after posix_acl to verfiy autorequire works
        file { '/opt/test3':
          ensure => directory,
          owner  => root,
          group  => root,
          mode   => '2770',
        }
        PUPPET
      end
    end
  end

  context 'on adding ACLs with overwriting existing ACLs' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        include posix_acl::requirements
        user { ['blub', 'blub2']:
          ensure => 'present',
        }
        posix_acl { '/opt/test3':
          action     => exact,
          permission => [
            'user::rwx',
            'group::rwx',
            'mask::rwx',
            'other::---',
            'user:blub2:r-x',
          ],
          provider   => posixacl,
          recursive  => false,
          require => User['blub2'],
        }
        # we declare the file resource after posix_acl to verfiy autorequire works
        file { '/opt/test3':
          ensure => directory,
          owner  => root,
          group  => root,
          mode   => '2770',
        }
        PUPPET
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'posix_acl purging ACLs' do
  context 'on a simple acl with an additional user' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        include posix_acl::requirements
        user { 'blub':
          ensure => 'present',
        }
        file { '/opt/test':
          ensure => directory,
          owner  => root,
          group  => root,
          mode   => '2770',
        }
        -> posix_acl { '/opt/test':
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
        PUPPET
      end
    end
  end

  context 'on a simple acl with no additional user and defaults' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET2
        include posix_acl::requirements
        file { '/opt/test5':
          ensure => directory,
          owner  => root,
          group  => root,
          mode   => '2770',
        }
        -> posix_acl { '/opt/test5':
          action     => exact,
          permission => [
            'user::rwx',
            'group::rwx',
            'mask::rwx',
            'other::---',
            'default:user::rwx',
            'default:group::rwx',
            'default:mask::rwx',
            'default:other::---',
          ],
          provider   => posixacl,
          recursive  => false,
        }
        PUPPET2
      end
    end
  end
end

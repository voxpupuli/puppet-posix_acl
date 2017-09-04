require File.join(File.dirname(__FILE__), '..', 'acl')

Puppet::Type.type(:posix_acl).provide(:genericacl, :parent => Puppet::Provider::Acl) do

end

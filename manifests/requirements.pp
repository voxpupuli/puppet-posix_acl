class acl::requirements {
  package{'acl':
    ensure => 'present',
  } -> Acl<| |>
}

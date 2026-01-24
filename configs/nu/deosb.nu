# we assume asset_unpacker and asset_packer are in PATH or otherwise accessible
export def deosb [p:path] {
  let tmpdir = (mktemp -d)
  asset_unpacker $p ($tmpdir)/
  let content = (open ($tmpdir)/_metadata | from json)
  rm -rf ($tmpdir)
  let updated = $content | upsert requires? { |t| $t.requires? | default [] | where (not ($it =~ "opensb_base")) }
  { before: $content, after: $updated }
}

# Change Log

## [Unreleased](https://github.com/infinitered/authority_ecto/tree/HEAD)

[Full Changelog](https://github.com/infinitered/authority_ecto/compare/v0.1.2...HEAD)

**Closed issues:**

- Missing @impl for function get\_token/1 callback \(specified in Authority.Tokenization\) [\#35](https://github.com/infinitered/authority_ecto/issues/35)
- Primary Key of UUID throws test error [\#34](https://github.com/infinitered/authority_ecto/issues/34)
- Accounts.get\_token returns hashed token instead of raw token [\#33](https://github.com/infinitered/authority_ecto/issues/33)
- Avoid reading/deleting the locks on every request [\#24](https://github.com/infinitered/authority_ecto/issues/24)

**Merged pull requests:**

- Document the context generator and Authority.Enum [\#32](https://github.com/infinitered/authority_ecto/pull/32) ([rzane](https://github.com/rzane))
- Restore the locking behavior [\#31](https://github.com/infinitered/authority_ecto/pull/31) ([rzane](https://github.com/rzane))
- Authority.Ecto.Enum [\#29](https://github.com/infinitered/authority_ecto/pull/29) ([rzane](https://github.com/rzane))
- Faster dev cycle for integration tests [\#28](https://github.com/infinitered/authority_ecto/pull/28) ([rzane](https://github.com/rzane))
- Don't attempt to HMAC a nil value [\#27](https://github.com/infinitered/authority_ecto/pull/27) ([rzane](https://github.com/rzane))
- Generate tests [\#26](https://github.com/infinitered/authority_ecto/pull/26) ([rzane](https://github.com/rzane))
- Lock/unlock around the tokenize event [\#25](https://github.com/infinitered/authority_ecto/pull/25) ([rzane](https://github.com/rzane))
- Context generator [\#22](https://github.com/infinitered/authority_ecto/pull/22) ([rzane](https://github.com/rzane))

## [v0.1.2](https://github.com/infinitered/authority_ecto/tree/v0.1.2) (2018-02-07)
[Full Changelog](https://github.com/infinitered/authority_ecto/compare/v0.1.1...v0.1.2)

**Closed issues:**

- Typespecs aren't quite right [\#20](https://github.com/infinitered/authority_ecto/issues/20)

**Merged pull requests:**

- Fix typespecs on `change\_user/0` - `change\_user/2` [\#21](https://github.com/infinitered/authority_ecto/pull/21) ([danielberkompas](https://github.com/danielberkompas))

## [v0.1.1](https://github.com/infinitered/authority_ecto/tree/v0.1.1) (2018-01-22)
[Full Changelog](https://github.com/infinitered/authority_ecto/compare/v0.1.0...v0.1.1)

**Merged pull requests:**

- Require confirmation only if password changed [\#19](https://github.com/infinitered/authority_ecto/pull/19) ([danielberkompas](https://github.com/danielberkompas))

## [v0.1.0](https://github.com/infinitered/authority_ecto/tree/v0.1.0) (2018-01-22)
**Implemented enhancements:**

- put\_token\_expiration/4 [\#5](https://github.com/infinitered/authority_ecto/issues/5)
- put\_secure\_token/2 [\#4](https://github.com/infinitered/authority_ecto/issues/4)
- validate\_secure\_password/2 [\#3](https://github.com/infinitered/authority_ecto/issues/3)
- put\_encrypted\_password/3 [\#2](https://github.com/infinitered/authority_ecto/issues/2)
- Extract Authority.Template [\#1](https://github.com/infinitered/authority_ecto/issues/1)

**Closed issues:**

- File structure? [\#15](https://github.com/infinitered/authority_ecto/issues/15)
- The token deletion in update\_user seems a little overzealous [\#12](https://github.com/infinitered/authority_ecto/issues/12)
- Prepare documentation for 0.1.0 release [\#6](https://github.com/infinitered/authority_ecto/issues/6)

**Merged pull requests:**

- \[\#6\] Prepare for release [\#18](https://github.com/infinitered/authority_ecto/pull/18) ([danielberkompas](https://github.com/danielberkompas))
- Reorganize file structure [\#17](https://github.com/infinitered/authority_ecto/pull/17) ([danielberkompas](https://github.com/danielberkompas))
- Allow `tokenize/2` to accept a user struct [\#16](https://github.com/infinitered/authority_ecto/pull/16) ([rzane](https://github.com/rzane))
- Ecto.Changeset might not be imported in this context [\#14](https://github.com/infinitered/authority_ecto/pull/14) ([rzane](https://github.com/rzane))
- \[\#12\] Expire tokens instead of deleting them [\#13](https://github.com/infinitered/authority_ecto/pull/13) ([danielberkompas](https://github.com/danielberkompas))
- Extract Template from Authority [\#11](https://github.com/infinitered/authority_ecto/pull/11) ([danielberkompas](https://github.com/danielberkompas))
- validate\_secure\_password [\#10](https://github.com/infinitered/authority_ecto/pull/10) ([rzane](https://github.com/rzane))
- \[\#4\] Add Authority.Ecto.HMAC, put\_token/2 [\#9](https://github.com/infinitered/authority_ecto/pull/9) ([danielberkompas](https://github.com/danielberkompas))
- Implement put\_token\_expiration/3 [\#8](https://github.com/infinitered/authority_ecto/pull/8) ([rzane](https://github.com/rzane))
- Implement put\_encrypted\_password/3 [\#7](https://github.com/infinitered/authority_ecto/pull/7) ([rzane](https://github.com/rzane))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
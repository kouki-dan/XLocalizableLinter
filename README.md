# XLocalizableLinter

Find unused Localizable string resources

# Try it out

## Prepare

```bash
git clone git@github.com:kouki-dan/XLocalizableLinter.git
cd XLocalizableLinter
```

## Success

```bash
swift run xlocalizablelint example/example.xcodeproj
```

## Failure

```bash
swift run xlocalizablelint exampleHasUnusedKey/exampleHasUnusedKey.xcodeproj
```
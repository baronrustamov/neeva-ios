#!/bin/sh

while getopts "eih" option; do
  case $option in
    e) # export
       if [ "$#" -lt 2 ]; then
         echo "missing argument: export directory"
         exit
       fi
       xcodebuild -exportLocalizations -localizationPath $2 -exportLanguage en
       ;;
    i) # import
       if [ "$#" -lt 2 ]; then
         echo "missing argument: import directory"
         exit
       fi
       #sed -i '' -e 's/fr-FR/fr/' $2/fr-FR/en.xliff
       #xcodebuild -importLocalizations -localizationPath $2/fr-FR/en.xliff
       #sed -i '' -e 's/de-DE/de/' $2/de-DE/en.xliff
       #xcodebuild -importLocalizations -localizationPath $2/de-DE/en.xliff
       #sed -i '' -e 's/es-ES/es/' $2/es-ES/en.xliff
       #xcodebuild -importLocalizations -localizationPath $2/es-ES/en.xliff
       cp -r $2/en-GB $2/en-AU
       sed -i '' -e 's/en-GB/en-AU/' $2/en-AU/en.xliff
       xcodebuild -importLocalizations -localizationPath $2/en-AU/en.xliff
       cp -r $2/en-GB $2/en-NZ
       sed -i '' -e 's/en-GB/en-NZ/' $2/en-NZ/en.xliff
       xcodebuild -importLocalizations -localizationPath $2/en-NZ/en.xliff
       #xcodebuild -importLocalizations -localizationPath $2/en-GB/en.xliff
       #cp -r $2/en-GB $2/en-CA
       #sed -i '' -e 's/en-GB/en-CA/' $2/en-CA/en.xliff
       #xcodebuild -importLocalizations -localizationPath $2/en-CA/en.xliff
       echo "### Done importing all xliff files ###"
       echo "Don't forget to commit and push the changes"
       ;;
    h) # help
       echo "-e [export_dir]: export localization file to a specific directory"
       echo "-i [import_dir]: import Smartling localization files from a specific directory"
       exit
  esac
done


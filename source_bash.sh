for file in $(find . -iname ".bash_*"); do
  echo "Loading $file";
  . $file;
done

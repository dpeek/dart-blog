import "dart:io";

import 'package:markdown/markdown.dart' show markdownToHtml;
import 'package:html5lib/parser.dart';
import 'package:yaml/yaml.dart';
import 'package:intl/intl.dart';

void main() {
  var posts = [];
  new Directory("post").listSync().forEach((path) {
    if (path is File) {
      if (new Path(path.fullPathSync()).extension == "markdown") {
        posts.add(readPost(path));
      }
    }
  });
  
  var content = '';
  posts.reversed.forEach((post) {
    content = '$content${post.html}';
  });
  var html = createHtml(content);
  new File('output/index.html').writeAsString(html, mode:FileMode.WRITE, encoding:Encoding.UTF_8);
}

var _RE_FRONT = new RegExp(r'---\n((.+\n)+)---', multiLine:true);

class Post {
  String title;
  String content;
  DateTime date;
  
  Post(this.title, this.content, this.date);
  
  String get dateString {
    return new DateFormat("EEEE, d MMMM y", "en_US").format(date);
  }
  
  String get html => '<article>$headerHtml$contentHtml</article>';
  String get headerHtml => '<header><h1>$title</h1><span>$dateString</span></header>';
  String get contentHtml => '<div>${markdownToHtml(content)}</div>';
}

Post readPost(file) {
  var content = file.readAsStringSync(Encoding.UTF_8);
  
  // Get the front matter.
  var match = _RE_FRONT.firstMatch(content);
  var front= new Map();
  if (match != null) {
    loadYaml(match[1]).forEach((k, v) => front[k] = v);
    content = content.substring(match.end).trim();
  }
  return new Post(front['title'], content, DateTime.parse(front['date']));
}

void writeMarkdown(content, path) {
  content = createHtml(content);
  path = "${path.substring(0, path.lastIndexOf('.') + 1)}html";
  print("compiled $path");
  new File(path).writeAsString(content, mode:FileMode.WRITE, encoding:Encoding.UTF_8);
}

String createHtml(String content) {
  return
'''<html>
<head>
  <title>Dartful</title>
  <link href='styles.css' rel='stylesheet' type='text/css'>
  <link rel="shortcut icon" href="favicon.ico">
</head>
<body>
  <div id='content'>
    <header id='banner'>
      <h1>Dartful</h1>
    </header>
    $content
  </div>
</body>
</html>''';
}
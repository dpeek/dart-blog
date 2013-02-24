import "dart:io";

import 'package:markdown/markdown.dart' show markdownToHtml;
import 'package:html5lib/parser.dart';
import 'package:yaml/yaml.dart';
import 'package:intl/intl.dart';

void main() {
  var files = getMarkdownFiles();
  var posts = files.map(readPost).toList();
  writeIndex(posts);
  posts.forEach(writePost);
}

/// Get a list of all markdown files in the site.
List<File> getMarkdownFiles() {
  var entries = new Directory("post").listSync();
  entries.retainMatching((entry) {
    return entry is File 
        && new Path(entry.fullPathSync()).extension == "markdown";
  });
  return entries;
}

var _RE_FRONT = new RegExp(r'---\n((.+\n)+)---', multiLine:true);

/// Reads a post file from disk and returns a Post model.
Post readPost(File file) {
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

/// Writes the sites index pags, containing all posts.
void writeIndex(List<Post> posts) {
  var content = '';
  posts.reversed.forEach((post) {
    content = '$content${post.html}';
  });
  var html = createHtml(content);
  new File('output/index.html').writeAsString(html, mode:FileMode.WRITE, encoding:Encoding.UTF_8);
}

// Writes and individual post page.
void writePost(Post post) {
  // write post
}

/// The model for a post.
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

/// An HTML helper until we sort out templates.
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

import 'dart:io';

import 'package:markdown/markdown.dart' show markdownToHtml;
import 'package:html5lib/parser.dart';
import 'package:yaml/yaml.dart';
import 'package:intl/intl.dart';

var deploy = new Directory('deploy');
var theme = new Directory('theme');
var post = new Directory('post');

var title = "Dartful";

void main() {
  prepareDeploy();
  var files = getMarkdownFiles();
  var posts = files.map(readPost).toList();
  writeIndex(posts);
  posts.forEach(writePost);
}

/// Prepare the deploy directory.
void prepareDeploy() {
  if (!deploy.existsSync()) deploy.createSync();
  theme.list().onFile = (f) {
    var path = new Path(f);
    copyFile(f, '${deploy.path}/${path.filename}');
  };
}

/// Copy a file from [input] to [output]
void copyFile(String input, String output) {
  final inStream = new File(input).openInputStream();
  final outStream = new File(output).openOutputStream(FileMode.WRITE);
  inStream.pipe(outStream);
}

/// Get a list of all markdown files in the site.
List<File> getMarkdownFiles() {
  if (!post.existsSync()) return [];
  var entries = post.listSync();
  entries.retainMatching((entry) {
    return entry is File 
        && new Path(entry.fullPathSync()).extension == 'markdown';
  });
  return entries;
}

var _RE_FRONT = new RegExp(r'---\n((.+\n)+)---', multiLine:true);
var _RE_PREVIEW = new RegExp(r'\n\n--\n\n', multiLine:true);

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
  
  var preview = content;
  var full = content;
  
  var index = content.indexOf('\n\n--\n\n');
  if (index > -1) {
    preview = content.substring(0, index);
    full = content.split('\n\n--\n\n').join("\n\n");
  }
  
  var pwd = new Directory.current();
  var path = file.fullPathSync().substring(pwd.path.length + post.path.length + 2);
  var parts = path.split('-');
  var dir = parts.getRange(0, 3).join("/");
  var name = parts.getRange(3, parts.length - 3).join("-");
  name = name.replaceFirst('.markdown', '.html');
  path = '$dir/$name';
  return new Post(path, front['title'], preview, full, DateTime.parse(front['date']));
}

/// Writes the sites index pags, containing all posts.
void writeIndex(List<Post> posts) {
  new File('${deploy.path}/index.html').writeAsString(indexTemplate(posts), 
      mode:FileMode.WRITE, encoding:Encoding.UTF_8);
}

// Writes and individual post page.
void writePost(Post post) {
  var path = new Path('${deploy.path}/${post.path}');
  
  var dir = new Directory.fromPath(path.directoryPath);
  if (!dir.existsSync()) dir.createSync(recursive:true);
  
  new File.fromPath(path).writeAsString(postTemplate(post), 
      mode:FileMode.WRITE, encoding:Encoding.UTF_8);
}

/// The model for a post.
class Post {
  String path;
  String title;
  String preview;
  String content;
  DateTime date;
  
  Post(this.path, this.title, this.preview, this.content, this.date);
  
  String get dateString {
    return new DateFormat('EEEE, d MMMM y', 'en_US').format(date);
  }
}

// templates

String indexTemplate(List<Post> posts) { return
'''<html>
<head>
  <title>$title</title>
  <link href='styles.css' rel='stylesheet' type='text/css'>
  <link rel="shortcut icon" href="favicon.ico">
</head>
<body>
  <div id='content'>
    <header id='banner'>
      <h1>Dartful</h1>
    </header>
    ${posts.map(postPartial).join('')}
  </div>
</body>
</html>''';
}

String postPartial(Post post) { return
'''<article>
  <header>
    <a href="${post.path}"><h1>${post.title}</h1></a>
    <span>${post.dateString}</span>
  </header>
  <div>${markdownToHtml(post.preview)}</div>
</article>''';
}

String postTemplate(Post post) { return
'''<html>
<head>
  <title>$title - ${post.title}</title>
  <link href='../../../styles.css' rel='stylesheet' type='text/css'>
  <link rel="shortcut icon" href="favicon.ico">
</head>
<body>
  <div id='content'>
    <header id='banner'>
      <h1>Dartful</h1>
    </header>
    <article>
      <header>
        <h1>${post.title}</h1>
        <span>${post.dateString}</span>
      </header>
      <div>${markdownToHtml(post.content)}</div>
    </article>
  </div>
</body>
</html>''';
}
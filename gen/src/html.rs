use pulldown_cmark::HeadingLevel;

struct HTMLBuf {
    nodes: Vec<String>,
    to_close: Vec<String>,
}

impl HTMLBuf {
    fn new() -> HTMLBuf {
        HTMLBuf {
            nodes: vec![],
            to_close: vec![],
        }
    }

    fn open(&mut self, name: &str) {
        self.nodes
            .push(format!("{}<{}>\n", "  ".repeat(self.to_close.len()), name));
        self.to_close.push(name.to_string());
    }

    fn push(&mut self, s: &str) {
        self.nodes.push("  ".repeat(self.to_close.len()));
        self.nodes.push(s.to_string());
        self.nodes.push("\n".to_string());
    }

    fn close(&mut self) {
        let name = self.to_close.pop().unwrap();
        self.nodes
            .push(format!("{}</{}>\n", "  ".repeat(self.to_close.len()), name));
    }

    fn to_string(&self) -> String {
        let mut s = self.nodes.join("");
        for (index, name) in self.to_close.iter().enumerate().rev() {
            s.push_str(&format!("{}</{}>\n", "  ".repeat(index), name));
        }
        s
    }
}

pub fn toc(headings: &Vec<(HeadingLevel, String)>) -> String {
    let mut hb = HTMLBuf::new();

    let from = if headings.len() > 0 && headings[0].0 == HeadingLevel::H1 {
        1
    } else {
        0
    };

    let mut current_level = HeadingLevel::H2;
    for (lv, s) in headings.iter().skip(from) {
        if *lv > current_level {
            hb.open("ul");
            current_level = *lv;
        } else if *lv < current_level {
            hb.close(); // close li
            hb.close(); // close ul
            hb.close(); // close li
            current_level = *lv;
        }
        hb.open("li");
        hb.push(&s);
    }

    let html = hb.to_string();

    if html == "" {
        "".to_string()
    } else {
        format!("<ul class=toc>\n{}</ul>", html).to_string()
    }
}

#[cfg(test)]
use pretty_assertions::assert_eq;

#[test]
fn test_toc() {
    assert_eq!(toc(&vec![]), "");
    assert_eq!(
        toc(&vec![
            (HeadingLevel::H1, "foo".to_string()),
            (HeadingLevel::H2, "bar".to_string()),
            (HeadingLevel::H3, "baz".to_string()),
            (HeadingLevel::H2, "quux".to_string()),
        ]),
        r#"<ul class=toc>
<li>
  bar
  <ul>
    <li>
      baz
    </li>
  </ul>
</li>
<li>
  quux
</li>
</ul>"#
    );
}

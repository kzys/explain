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
            .push("  ".to_string().repeat(self.to_close.len()));
        self.nodes.push(format!("<{}>\n", name));
        self.to_close.push(name.to_string());
    }

    fn push(&mut self, s: &str) {
        self.nodes.push("  ".repeat(self.to_close.len()));
        self.nodes.push(s.to_string());
        self.nodes.push("\n".to_string());
    }

    fn close(&mut self) {
        let name = self.to_close.pop().unwrap();
        self.nodes.push(format!("</{}>", name));
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
        if *lv != current_level {
            hb.open("ul");
            current_level = *lv;
        }
        hb.open("li");
        hb.push(&s);
    }

    let html = hb.to_string();

    if html == "" {
        "".to_string()
    } else {
        format!("<ul class=toc>{}</ul>", html).to_string()
    }
}

#[test]
fn test_toc() {
    assert_eq!(toc(&vec![]), "");
    assert_eq!(
        toc(&vec![
            (HeadingLevel::H1, "H1".to_string()),
            (HeadingLevel::H2, "H2".to_string()),
            (HeadingLevel::H3, "H3".to_string()),
        ]),
        r#"<ul class=toc><li>
  H2
  <ul>
    <li>
      H3
    </li>
  </ul>
</li>
</ul>"#
    );
}

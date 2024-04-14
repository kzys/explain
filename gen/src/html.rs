use pulldown_cmark::HeadingLevel;

pub fn toc(headings: &Vec<(HeadingLevel, String)>) -> String {
    let mut html_output = String::new();

    let mut close: Vec<String> = vec![];

    let from = if headings.len() > 0 && headings[0].0 == HeadingLevel::H1 {
        1
    } else {
        0
    };

    let mut current_level = HeadingLevel::H2;
    for (lv, s) in headings.iter().skip(from) {
        if *lv != current_level {
            html_output.push_str("<ul>\n");
            current_level = *lv;
            close.push("ul".to_string());
        }
        html_output.push_str(&format!("<li>{}\n", s));
        close.push("li".to_string());
    }
    for tag in close.iter().rev() {
        html_output.push_str(&format!("</{}>\n", tag));
    }

    if html_output == "" {
        "".to_string()
    } else {
        format!("<ul class=toc>{}</ul>", html_output).to_string()
    }
}

#[test]
fn test_toc() {
    assert_eq!(toc(&vec![]), "");
}

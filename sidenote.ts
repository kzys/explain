import {Node, FootnoteDefinition, FootnoteReference, Paragraph} from 'mdast';
import {VFile} from 'vfile';
import {visit, CONTINUE} from 'unist-util-visit'

export function remarkSidenote() {
    function f(tree: Node, file: VFile) {
        let defs = {}
        visit(tree, ['paragraph', 'footnoteDefinition'], (node: Node, index: number|undefined, parent: any) => {
            if (node.type == 'paragraph') {
                let p = node as Paragraph;
                let c = p.children.find(c => c.type == 'footnoteReference')
                if (c) {
                    let ref = c as FootnoteReference;
                    let def = defs[ref.identifier] as FootnoteDefinition;
                    console.log(p.children)
                    parent.children = [
                        ...parent.children.slice(0, index),
                        p,
                        {
                            type: 'paragraph',
                            children: [
                                {type: 'html', value: '<aside>'},
                                ...def.children,
                                {type: 'html', value: '</aside>'},
                            ]},
                        ...parent.children.slice(index!+1),
                    ]
                }
            } else if (node.type == 'footnoteDefinition') {
                let def = node as FootnoteDefinition;
                defs[def.identifier] = def;
            }
            return CONTINUE;
         }, true)
      }
    return f;
}

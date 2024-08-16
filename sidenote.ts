import {Node, FootnoteDefinition, FootnoteReference, Paragraph} from 'mdast';
import {VFile} from 'vfile';
import {visit, CONTINUE, SKIP} from 'unist-util-visit'

export function remarkSidenote() {
    function f(tree: Node, file: VFile) {
        let defs = {}
        visit(tree, ['footnoteDefinition'], (node: Node, index: number|undefined, parent: any) => {
            if (node.type != 'footnoteDefinition') {
                return CONTINUE;
            }
            let def = node as FootnoteDefinition;
            defs[def.identifier] = def;

            parent.children = [
                ...parent.children.slice(0, index),
                ...parent.children.slice(index!+1),
            ]
            return SKIP;
         })

         let fnIndex = 1;
         visit(tree, ['footnoteReference'], (node: Node, index: number|undefined, parent: any) => {
            if (node.type != 'footnoteReference') {
                return CONTINUE;
            }
            let ref = node as FootnoteReference;
            let def = defs[ref.identifier] as FootnoteDefinition;
            console.log(def)
            let id = `user-content-fn-${def.identifier}`
            parent.children = [
                ...parent.children.slice(0, index),
                ref,
                {
                    type: 'html',
                    value: `<small class=sidenote id=${id}>${fnIndex} `,
                },
                ...(def.children[0] as Paragraph).children,
                {type: 'html', value: '</small>'},
                ...parent.children.slice(index!+1),
            ]
            fnIndex++;
            return CONTINUE;
         })
      }
    return f;
}

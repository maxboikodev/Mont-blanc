({
    doInit: function (component, event, helper) {
        console.log("Initialiation completed");
        // build a list of 100 words

    let mode = component.get ("v.mode");
        let wordsqnt;
        let itemsize; 

        if (mode == "hard"){ 
            wordsqnt = 36;
            itemsize = 2;
            } else if (mode == "medium") {
                wordsqnt = 24;
                itemsize = 3;
                } else {
                    wordsqnt = 12;
                    itemsize = 4;
            }

        component.set ("v.Itemsize", itemsize);
        const words = helper.getWords(wordsqnt);
        component.set("v.words", words);

        console.log("Words: " + words);
        // get win word
        const winWord = helper.getWinWord(words);
        component.set("v.winWord", winWord);
        console.log("Win word: " + helper.getWinWord(words));
    },

    doRender: function (component, event, helper) {
        console.log("Render completed");
    }
});

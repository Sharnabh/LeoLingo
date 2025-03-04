struct Poem {
    let title: String
    let content: String
    let audioFileName: String
    let difficulty: Difficulty
    let scoreMultiplier: Int
    let imageName: String
    
    enum Difficulty: String {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }
    
    static let poems: [Poem] = [
        Poem(title: "Twinkle Twinkle", 
             content: "Twinkle, twinkle, little star\nHow I wonder what you are\nUp above the world so high\nLike a diamond in the sky",
             audioFileName: "twinkle_twinkle",
             difficulty: .easy,
             scoreMultiplier: 1,
             imageName: "Twinkle"),
        
        Poem(title: "Baa Baa Black Sheep",
             content: "Baa, baa, black sheep\nHave you any wool?\nYes sir, yes sir\nThree bags full",
             audioFileName: "baa_baa",
             difficulty: .easy,
             scoreMultiplier: 1,
             imageName: "Sheep"),
        
        Poem(title: "Humpty Dumpty",
             content: "Humpty Dumpty sat on a wall\nHumpty Dumpty had a great fall\nAll the king's horses and all the king's men\nCouldn't put Humpty together again",
             audioFileName: "humpty_dumpty",
             difficulty: .medium,
             scoreMultiplier: 2,
             imageName: "HumptyDumpty"),
        
        Poem(title: "Jack and Jill",
             content: "Jack and Jill went up the hill\nTo fetch a pail of water\nJack fell down and broke his crown\nAnd Jill came tumbling after",
             audioFileName: "jack_jill",
             difficulty: .medium,
             scoreMultiplier: 2,
             imageName: "Jill"),
        
        Poem(title: "Mary Had a Little Lamb",
             content: "Mary had a little lamb\nIts fleece was white as snow\nAnd everywhere that Mary went\nThe lamb was sure to go",
             audioFileName: "mary_lamb",
             difficulty: .hard,
             scoreMultiplier: 3,
             imageName: "Lamb")
    ]
} 
(import owlready2 *)

(setv onto (get-ontology "https://progdrum.github.io/drumheads_cymbals.owl#"))

(defn get-default [dictionary key [default None]]
    "Like `get`, but with a default if key is not present."
    (try
      (get dictionary key)
      (except [KeyError]
        default)))

;; Macro for defining entities with all options in one command
(defmacro defentity [ent-name parent [attributes {}]]
  (import hy.models [Symbol])
  `(defclass ~(Symbol ent-name) [~(Symbol parent)]
     (setv equivalent-to (get-default ~attributes ':equivalent-to None)
           label (get-default ~attributes ':label [])
           comment (get-default ~attributes ':comments [])
           seeAlso (get-default ~attributes ':see-also [])
           versionInfo (get-default ~attributes ':version-info [])
           deprecated (get-default ~attributes ':is-deprecated [])
           incompatibleWith (get-default ~attributes ':incompatible-with [])
           backwardCompatibleWith (get-default ~attributes ':backward-compatible-with [])
           isDefinedBy (get-default ~attributes ':is-defined-by []))))

;; Lay out the drumhead-related classes
(with [onto]

  (defentity "Drumhead" "Thing"
    {:comments ["Generic drumhead class"]
     :version-info ["0.1"]})

  (defclass is-snare-side [(>> Drumhead bool) FunctionalProperty])

  (defentity "Plies" "Thing"
    {:comments ["Drum heads have one or more plies of film."
                "Number of plies a drumhead has"]
     :version-info ["0.1"]})

  (defclass has-plies [(>> Drumhead Plies) FunctionalProperty])

  (defentity "OnePly" "Plies"
    {:equivalent-to [(& Plies (has-plies.exactly 1))]
     :version-info  ["0.1"]})
  (defentity "TwoPly" "Plies"
    {:equivalent-to [(& Plies (has-plies.exactly 2))]
     :version-info ["0.1"]})
  (defentity "ThreePly" "Plies"
    {:equivalent-to [(& Plies (has-plies.exactly 3))]
     :version-info ["0.1"]})
  (AllDisjoint [OnePly TwoPly ThreePly])
  
  (defclass has-thickness [(>> Drumhead float) FunctionalProperty])
  (defclass has-twoply-ply1-thickness [(>> TwoPly float) FunctionalProperty])
  (defclass has-twoply-ply2-thickness [(>> TwoPly float) FunctionalProperty])
  (defclass has-threeply-ply1-thickness [(>> ThreePly float) FunctionalProperty])
  (defclass has-threeply-ply2-thickness [(>> ThreePly float) FunctionalProperty])
  (defclass has-threeply-ply3-thickness [(>> ThreePly float) FunctionalProperty])

  (defentity "Surface" "Thing"
    {:comments ["Drum heads can have a variety of surfaces that affect the feel, attack, and tone."]
     :version-info ["0.1"]})
  (defentity "Coated" "Surface"
    {:comments ["Coated surfaces are good for brush players."
                "Coated surfaces give a bit warmer tone."]
     :version-info ["0.1"]})
  (defentity "Clear" "Surface"
    {:comments ["Clear heads are a bit brighter and have more attack than coated heads."
                "Clear heads are not so good for playing with brushes."]
     :version-info ["0.1"]})
  (defentity "Suede" "Surface"
    {:version-info ["0.1"]})
  (defentity "Ebony" "Surface"
    {:version-info ["0.1"]})
  (defentity "SimulatedSkin" "Surface"
    {:comments ["These heads attempt to replicate the appearance, feel, and tone of skin drum heads of old."]
     :version-info ["0.1"]})
  (defentity "Frosted" "Surface"
    {:version-info ["0.1"]})
  (defentity "Hazy" "Surface"
    {:comments ["These drum heads have a hazy coating and lie between clear and coated heads sonically."]
     :version-info ["0.1"]})
  (defentity "Etched" "Surface"
    {:version-info ["0.1"]})
  (AllDisjoint [Coated Clear Suede Ebony SimulatedSkin Frosted Hazy Etched])

  (defclass has-surface-type [(>> Drumhead Surface) FunctionalProperty])
  
  (defentity "Dampening" "Thing"
    {:comments ["Dampening mechanisms help to reduce unwanted overtones."
                "Too much dampening can deaden the sound of the drum."]
     :version-info ["0.1"]})
  (defentity "InlayRing" "Dampening"
    {:comments ["These are plastic rings, usually underneath the head."]
     :version-info ["0.1"]
     :see-also ["Ring"]})
  (defentity "Dot" "Dampening"
    {:comments ["An additional ply in the middle of the head that is smaller in diameter than the head."]
     :version-info ["0.1"]})
  (defentity "CenterDot" "Dot"
    {:version-info ["0.1"]
     :see-also ["Dot" "ReverseDot"]})
  (defentity "ReverseDot" "Dot"
    {:version-info ["0.1"]
                  :see-also ["Dot" "CenterDot"]})
  (defentity "Holes" "Dampening"
    {:comments ["Holes allow additional air to escape upon striking."]
     :version-info ["0.1"]})
  (defentity "Ring" "Dampening"
    {:version-info ["0.1"]
     :see-also "InlayRing"})
  (defentity "Oil" "Dampening"
    {:comments ["Requires at least two plies."]
     :version-info ["0.1"]
     :see-also ["TwoPly" "ThreePly"]})

  (defclass has-dampening [(>> Drumhead Dampening)])
  (defclass dot-thickness [(>> Dot float) FunctionalProperty])

  (defentity "Manufacturer" "Thing"
    {:version-info ["0.1"]})
  (defentity "Remo" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Evans" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Aquarian" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Other" "Manufacturer"
    {:version-info ["0.1"]})
  (AllDisjoint [Remo Evans Aquarian Other]))

(defclass has-manufacturer [(>> Drumhead Manufacturer) FunctionalProperty])

;; Lay out the cymbal-related classes
(with [onto]

  (defentity "Cymbal" "Thing"
    {:comments ["Generic cymbal class"]
     :version-info ["0.1"]})
  (defentity "Crash" "Cymbal"
    {:comments ["May also be rideable"]
     :see-also ["Ride"]
     :version-info ["0.1"]})
  (defentity "Ride" "Cymbal"
    {:comments ["May also be crashable."]
     :see-also ["Crash"]
     :version-info ["0.1"]})
  (defentity "FlatRide" "Ride"
    {:comments ["Ride cymbals without a pronounced bell"]
     :see-also ["Ride"]
     :version-info ["0.1"]})
  (defentity "CrashRide" "Cymbal"
    {:equivalent-to [(& Crash Ride)]
     :comments ["A cymbal made for both crashing and riding"]
     :see-also ["Crash" "Ride"]})
  (defentity "Splash" "Cymbal"
    {:version-info ["0.1"]})
  (defentity "HiHat" "Cymbal"
    {:version-info ["0.1"]})
  (defentity "China" "Cymbal"
    {:version-info ["0.1"]})
  (defentity "Pang" "China"
    {:version-info ["0.1"]})
  (defentity "Swish" "China"
    {:version-info ["0.1"]})
  (defentity "Lion" "China"
    {:version-info ["0.1"]})
  (defentity "Efx" "Cymbal"
    {:comments ["Miscellaneous effects cymbals"]
     :version-info ["0.1"]})
  (defentity "Gong" "Cymbal"
    {:version-info ["0.1"]})
  (defentity "TamTam" "Gong"
    {:version-info ["0.1"]})
  (defentity "NippleGong" "Gong"
    {:version-info ["0.1"]})
  (AllDisjoint [Crash HiHat China Gong])
  (AllDisjoint [Ride HiHat China Gong])

  (defentity "Alloy" "Thing"
    {:comments ["Different grades of brass and bronze yield different quality cymbals and gongs."
                "The bronze or brass alloy from which a cymbal is made"]
     :version-info ["0.1"]})
  (defentity "Brass" "Alloy"
    {:comments ["Typically cheap cymbals that come with beginner drum kits."]
     :version-info ["0.1"]})
  (defentity "B8" "Alloy"
    {:comments ["Commonly used for beginner/intermediate-level cymbals"
                "B8 alloy (92% copper, 8% tin)"]
     :version-info ["0.1"]})
  (defentity "B10" "Alloy"
    {:comments ["Intermediate-grade cymbals, typically"
                "B10 alloy (90% copper, 10% tin)"]
     :version-info ["0.1"]})
  (defentity "B20" "Alloy"
    {:comments ["Usually top-of-the-line cymbals"
                "B20 alloy (80% copper, 20% tin)"]
     :version-info ["0.1"]})
  (AllDisjoint [Brass B8 B10 B20])

  (defclass is-made-of [(>> Cymbal Alloy) FunctionalProperty])

  (defentity "Weight" "Thing"
    {:comments ["Cymbal weight is a major determiner of tone."
                "Thinner cymbals tend to be darker-sounding."
                "Thicker cymbals tend to be louder, brighter, and more cutting."]
     :version-info ["0.1"]})
  (defentity "PaperThin" "Weight"
    {:version-info ["0.1"]})
  (defentity "Thin" "Weight"
    {:version-info ["0.1"]})
  (defentity "MediumThin" "Weight"
    {:version-info ["0.1"]})
  (defentity "Medium" "Weight"
    {:version-info ["0.1"]})
  (defentity "MediumHeavy" "Weight"
    {:version-info ["0.1"]})
  (defentity "Heavy" "Weight"
    {:version-info ["0.1"]})
  (AllDisjoint [PaperThin Thin MediumThin Medium MediumHeavy Heavy])

  (defclass has-weight [(>> Cymbal Weight) FunctionalProperty])
  
  (defentity "Lathing" "Thing"
    {:comments ["Lathing or lack thereof on a cymbal"]
     :version-info ["0.1"]})

  (defclass has-lathing [(>> Cymbal Lathing)])
  (defclass has-hybrid-lathing [(>> Cymbal bool) FunctionalProperty])
  
  (defentity "Unlathed" "Lathing"
    {:version-info ["0.1"]})
  (defentity "Lathed" "Lathing"
    {:version-info ["0.1"]})
  (defentity "Hybrid" "Lathing"
    {:comments ["A cymbal that is partially lathed"]
     :version-info ["0.1"]
     :see-also ["Lathed" "Unlathed"]})

  (defentity "Bosphorus" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Istanbul" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Dream" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Meinl" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Sabian" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Zildjian" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Paiste" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Wuhan" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Stagg" "Manufacturer"
    {:version-info ["0.1"]})
  (defentity "Other" "Manufacturer"
    {:version-info ["0.1"]})
  (AllDisjoint [Bosphorus Istanbul Dream Meinl Sabian Zildjian Paiste Wuhan Stagg Other])
 
 (defclass has-manufacturer [(>> Cymbal Manufacturer) FunctionalProperty]))

;; Add some other classes that combine classes and properties
(with [onto]

  (defentity "ThickHead" "Drumhead"
    {:equivalent-to [(| (& Drumhead (has-thickness.min 11 float))
                        (& Drumhead (| TwoPly ThreePly)))]
     :version-info ["0.1"]
     :see-also ["Drumhead" "Plies" "TwoPly" "ThreePly"]})

  (defentity "ThinHead" "Drumhead"
    {:equivalent-to (& Drumhead OnePly (has-thickness.max 10 float))
     :version-info ["0.1"]
     :see-also ["Drumhead" "Plies" "OnePly"]}))

(onto.save "test_ontologies/dcyms.owl")


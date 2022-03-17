(import owlready2 *)
(require hyrule.let [let])

(setv onto (get-ontology "https://progdrum.github.io/drumheads_cymbals.owl#"))

(defn get-default [dictionary key [default None]]
    "Like `get`, but with a default if key is not present."
    (try
      (get dictionary key)
      (except [KeyError]
        default)))

;; TODO: Improve on this when unpack-mapping becomes available in macros.
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

  (defentity "StruckObject" "Thing"
    {:comments ["Objects that are struck."
                "Parent class of all struck objects."]})

  (defentity "Drumhead" "StruckObject"
    {:comments ["Generic drumhead class"]})

  (defclass is-snare-side [(>> Drumhead bool) FunctionalProperty])
  (defclass has-plies [(>> Drumhead int) FunctionalProperty])
  (defclass has-thickness [(>> Drumhead float) FunctionalProperty])

  (defentity "Surface" "Thing"
    {:comments ["Drum heads can have a variety of surfaces that affect the feel, attack, and tone."]})

  (defclass has-surface [(>> Drumhead Surface)])
  (defclass is-surface-of [(>> Surface Drumhead)]
    (setv inverse-property has-surface))
  
  (defentity "Dampening" "Thing"
    {:comments ["Dampening mechanisms help to reduce unwanted overtones."
                "Too much dampening can deaden the sound of the drum."]})
  (defentity "Dot" "Dampening"
    {:comments ["An additional ply in the middle of the head that is smaller in diameter than the head."]})

  (defclass has-dampening [(>> Drumhead Dampening)])
  (defclass is-dampening-for [(>> Dampening Drumhead)]
    (setv inverse-property has-dampening))
  (defclass dot-thickness [(>> Dot float) FunctionalProperty])

  (defentity "Manufacturer" "Thing")

  (defclass has-manufacturer [(>> StruckObject Manufacturer) FunctionalProperty])
  (defclass is-manufacturer-of [(>> Manufacturer StruckObject)]
    (setv inverse-property has-manufacturer)))

;; Lay out the cymbal-related classes
(with [onto]

  (defentity "Cymbal" "StruckObject"
    {:comments ["Generic cymbal class"]})
  (defentity "Crash" "Cymbal"
    {:comments ["May also be rideable"]})
  (defentity "Ride" "Cymbal"
    {:comments ["May also be crashable."]
     :see-also ["Crash"]})
  (defentity "FlatRide" "Ride"
    {:comments ["Ride cymbals without a pronounced bell"]})
  (defentity "CrashRide" "Cymbal"
    {:equivalent-to [(& Crash Ride)]
     :comments ["A cymbal made for both crashing and riding"]})
  (defentity "Splash" "Cymbal")
  (defentity "HiHat" "Cymbal")
  (defentity "China" "Cymbal")
  (defentity "Efx" "Cymbal"
    {:comments ["Miscellaneous effects cymbals"]})
  (defentity "Gong" "Cymbal")
  (defentity "TamTam" "Gong")
  (defentity "NippleGong" "Gong")
  (defentity "ChauGong" "TamTam")
  (AllDisjoint [Crash HiHat China Gong])
  (AllDisjoint [Ride HiHat China Gong])

  (defentity "Alloy" "Thing"
    {:comments ["Different grades of brass and bronze yield different quality cymbals and gongs."
                "The bronze or brass alloy from which a cymbal is made"]})
  (defentity "Brass" "Alloy"
    {:comments ["Typically cheap cymbals that come with beginner drum kits."]})
  (defentity "B8" "Alloy"
    {:comments ["Commonly used for beginner/intermediate-level cymbals"
                "B8 alloy (92% copper, 8% tin)"]})
  (defentity "B10" "Alloy"
    {:comments ["Intermediate-grade cymbals, typically"
                "B10 alloy (90% copper, 10% tin)"]})
  (defentity "B20" "Alloy"
    {:comments ["Usually top-of-the-line cymbals"
                "B20 alloy (80% copper, 20% tin)"]})
  (AllDisjoint [Brass B8 B10 B20])

  (defentity "Lathing" "Thing")
  (defentity "FullyLathed" "Lathing")
  (defentity "Unlathed" "Lathing")
  (defentity "Hybrid" "Lathing")
  
  (defclass is-made-of [(>> Cymbal Alloy) FunctionalProperty])
  (defclass has-weight [(>> Cymbal str) FunctionalProperty])
  (defclass is-lathed [(>> Cymbal bool)])
  (defclass has-lathing [(>> Cymbal Lathing) FunctionalProperty]))

;;;; Add some other classes to take into account for our attributes

(with [onto]
  
  ;; Drum types
  (defentity "Drum" "StruckObject"
    {:comments ["A membranophone that is struck to produce music"]})
  (defentity "SnareDrum" "Drum"
    {:comments ["A drum with wires on the bottom head to produce a snap, crackle, and pop!"]})
  (defentity "BassDrum" "Drum"
    {:comments ["A large, low-pitched drum"]})
  (defentity "TomTom" "Drum"
    {:comments ["Drums without snares of varying sizes and pitches"]})
  (defentity "Bucket" "Drum"
    {:comments ["Yeah, that's right. A bucket."]})
  (AllDisjoint [SnareDrum BassDrum TomTom Bucket])

  ;; What kinds of drums does the head go on? Will this work for getting me individuals later?
  (defclass goes-on [(>> Drumhead Drum)])
  (defclass takes-head [(>> Drum Drumhead)]
    (setv inverse-property goes-on))

  ;; Durability
  (defentity "Durability" "Thing")

  (defclass has-durability [(>> Drumhead Durability)])
  (defclass heads-with-durability [(>> Durability Drumhead)]
    (setv inverse-property has-durability))

  ;; Attack
  (defentity "Attack" "Thing")

  (defclass has-attack [(>> Drumhead Attack)])
  (defclass heads-with-attack [(>> Attack Drumhead)]
    (setv inverse-property has-attack))

  ;; Overtones
  (defentity "Overtones" "Thing")

  (defclass has-overtones [(>> Drumhead Overtones)])
  (defclass heads-with-overtones [(>> Overtones Drumhead)]
    (setv inverse-property has-overtones))

  ;; Responsiveness
  (defentity "Responsiveness" "Thing")

  (defclass has-responsiveness [(>> Drumhead Responsiveness) FunctionalProperty])
  (defclass heads-with-responsiveness [(>> Responsiveness Drumhead)]
    (setv inverse-functional-property has-responsiveness))  ; TODO: Figure this bitch out!

  ;; Sound
  (defentity "Sound" "Thing")

  (defclass has-sound [(>> Drumhead Sound)])
  (defclass heads-with-sound [(>> Sound Drumhead)]
    (setv inverse-property has-sound))

  ;; Sustain
  (defentity "Sustain" "Thing")

  (defclass has-sustain [(>> Drumhead Sustain)])
  (defclass heads-with-sustain [(>> Sustain Drumhead)]
    (setv inverse-property has-sustain)))

;; Add some other classes that combine classes and properties
(with [onto]

  (defentity "ThickHead" "Drumhead"
    {:equivalent-to [(& Drumhead
                        (|
                          (>= has-thickness 12)
                          (>= has-plies 2)))]})

  (defentity "ThinHead" "Drumhead"
    {:equivalent-to [(& Drumhead
                         (< has-thickness 12))]}))

;;;; Add instances to the ontology, beginning here!

;; Gather the dict for each page into one large dict
(import re
        json
        parse-page
        collections [ChainMap])
;; (setv drumheads (parse-page.parse-data))
;; (setv all-heads (ChainMap #*drumheads))

;; (with [f (open "drumhead_info.json" "w")]
;;   (f.write (json.dumps (dict all-heads))))

(with [data (open "drumhead_info.json" "r")]
  (setv all-heads (json.load data)))

(defn extract-number [val]
  "Given an alphanumeric value, retrieve just the number"
  (let [num-val (if (in "," val)
                    (get (.split val ",") 0)
                    val)]
    (if (not (in "." num-val))
        (float (get (re.findall r"(\d+)" num-val) 0))
        (float (get (re.findall r"(\d+\.\d)" num-val) 0)))))

;; Create instances from the attributes!
(with [onto]
  
  ; Log failures to a file for further reference
  (with [f (open "errors.txt" "w")]
    (for [(, k v) (all-heads.items)]

      ; Create/Name instance
      (setv drum-head (Drumhead (k.replace " " "_")))

      ; Attack
      (try
        (let [attack-lst []]
          (for [attack-val (.split (get v "Attack") ", ")]
            (cond [(= attack-val "Very Low") (attack-lst.append (Attack "VeryLowAttack"))]
                  [(= attack-val "Low") (attack-lst.append (Attack "LowAttack"))]
                  [(= attack-val "Moderate") (attack-lst.append (Attack "ModerateAttack"))]
                  [(= attack-val "High") (attack-lst.append (Attack "HighAttack"))]
                  [(= attack-val "Very High") (attack-lst.append (Attack "VeryHighAttack"))]))
          (setv (. drum-head has-attack) attack-lst))
        (except [KeyError]
          (f.write f"{k} is missing the 'Attack' key.\n")))

      ; Durability
      (try
        (let [dur-lst []]
          (for [dur-val (.split (get v "Durability") ", ")]
            (cond [(= dur-val "Very Low") (dur-lst.append (Durability "VeryLowDurability"))]
                  [(= dur-val "Low") (dur-lst.append (Durability "LowDurability"))]
                  [(= dur-val "Medium") (dur-lst.append (Durability "MediumDurability"))]
                  [(= dur-val "High") (dur-lst.append (Durability "HighDurability"))]
                  [(= dur-val "Very High") (dur-lst.append (Durability "VeryHighDurability"))]
                  [(= dur-val "Extreme") (dur-lst.append (Durability "ExtremeDurability"))]))
          (setv (. drum-head has-durability) dur-lst))
        (except [KeyError]
          (f.write f"{k} is missing the 'Durability' key.\n")))

      ; Overtones
      (try
        (let [ot-lst []]
          (for [ot-val (.split (get v "Overtones") ", ")]
            (cond [(= ot-val "Very Low") (ot-lst.append (Overtones "VeryLowOvertones"))]
                  [(= ot-val "Low") (ot-lst.append (Overtones "LowOvertones"))]
                  [(= ot-val "Moderate") (ot-lst.append (Overtones "ModerateOvertones"))]
                  [(= ot-val "High") (ot-lst.append (Overtones "HighOvertones"))]
                  [(= ot-val "Very High") (ot-lst.append (Overtones "VeryHighOvertones"))]))
          (setv (. drum-head has-overtones) ot-lst))
        (except [KeyError]
          (f.write f"{k} is missing the 'Overtones' key.\n")))

      ; Responsiveness
      (try
        (let [resp-val (get v "Responsiveness")]
          (cond [(= resp-val "Very Low")
                 (setv (. drum-head has-responsiveness)
                       (Responsiveness "VeryLowResponsiveness"))]
                [(= resp-val "Low")
                 (setv (. drum-head has-responsiveness) (Responsiveness "LowResponsiveness"))]
                [(= resp-val "Medium")
                 (setv (. drum-head has-responsiveness) (Responsiveness "MediumResponsiveness"))]
                [(= resp-val "High")
                 (setv (. drum-head has-responsiveness) (Responsiveness "HighResponsiveness"))]
                [(= resp-val "Very High")
                 (setv (. drum-head has-responsiveness)
                       (Responsiveness "VeryHighResponsiveness"))]))
        (except [KeyError]
          (f.write f"{k} is missing the 'Responsiveness' key.\n")))

      ; Sound
      (try
        (let [sound-lst []]
          (for [sound-val (.split (get v "Sound") ", ")]
            (cond [(= sound-val "Very Warm") (sound-lst.append (Sound "VeryWarm"))]
                  [(= sound-val "Warm") (sound-lst.append (Sound "Warm"))]
                  [(= sound-val "Balanced") (sound-lst.append (Sound "Balanced"))]
                  [(= sound-val "Bright") (sound-lst.append (Sound "Bright"))]
                  [(= sound-val "Very Bright") (sound-lst.append (Sound "VeryBright"))]))
          (setv (. drum-head has-sound) sound-lst))
        (except [KeyError]
          (f.write f"{k} is missing the 'Sound' key.\n")))

      ; Sustain
      (try
        (let [sustain-lst []]
          (for [sustain-val (.split (get v "Sustain") ", ")]
            (cond [(= sustain-val "Very Low") (sustain-lst.append (Sustain "VeryLowSustain"))]
                  [(= sustain-val "Low") (sustain-lst.append (Sustain "LowSustain"))]
                  [(= sustain-val "Moderate") (sustain-lst.append (Sustain "ModerateSustain"))]
                  [(= sustain-val "High") (sustain-lst.append (Sustain "HighSustain"))]
                  [(= sustain-val "Very High") (sustain-lst.append
                                                 (Sustain "VeryHighSustain"))]))
          (setv (. drum-head has-sustain) sustain-lst))
        (except [KeyError]
          (f.write f"{k} is missing the 'Sustain' key.\n")))

      ; Drum(s)
      (try
        (let [drum-lst []]
          (print f"DRUMHEAD: {k}")
          (for [drum-val (.split (get v "Drum") ", ")]
            (print f"DRUM: {drum-val}")
            (cond [(= drum-val "Snare Drum")
                   (.append (. drum-head goes-on) (SnareDrum "snare_drum"))]
                  [(= drum-val "Snare Side Resonant")
                   (.append (. drum-head goes-on) (SnareDrum "snare_drum"))]
                  [(= drum-val "Bass Drum")
                   (.append (. drum-head goes-on) (BassDrum "bass_drum"))]
                  [(= drum-val "Toms") (.append (. drum-head goes-on) (TomTom "tom_tom"))]
                  [(= drum-val "Bucket") (.append (. drum-head goes-on) (Bucket "bucket"))]))
                                ;          (setv (. drum-head goes-on) drum-lst)
;          (for [d drum-lst] (.append (. drum-head goes-on) d))
          (print f"GOES ON: {(. drum-head goes-on)}"))
        (except [KeyError]
          (f.write f"{k} is missing the 'Drum' key.")))

      ; Ply (there really, REALLY should only be one!)
      (try
        (setv (. drum-head has-plies) (extract-number (get-default v "Ply")))
        (except [KeyError]
          (f.write f"{k} is missing the 'Ply' key.\n")))

                                ; Thickness
      (try
        (setv (. drum-head has-thickness) (extract-number (get v "Total Thickness")))
        (except [KeyError]
          (f.write f"{k} is missing the 'Thickness' key.\n")))

                                ; Surface
      (try
        (let [surface-lst []]
          (for [surface-val (.split (get v "Surface") ", ")]
            (cond [(= surface-val "Synthetic Fiber") (surface-lst.append
                                                       (Surface "SimulatedSkin"))]
                  [(= surface-val "Coated") (surface-lst.append (Surface "Coated"))]
                  [(= surface-val "Clear") (surface-lst.append (Surface "Clear"))]
                  [(= surface-val "Etched") (surface-lst.append (Surface "Etched"))]
                  [(= surface-val "Suede") (surface-lst.append (Surface "Suede"))]
                  [(= surface-val "Hazy") (surface-lst.append (Surface "Hazy"))]
                  [(= surface-val "Frosted") (surface-lst.append (Surface "Frosted"))]
                  [(= surface-val "Ebony") (surface-lst.append (Surface "Ebony"))]))
          (.extend (. drum-head has-surface) surface-lst))
        (except [KeyError]
          (f.write f"{k} is missing the 'Surface' key.\n")))

      ; Dampening
      (try
        (for [damp-val (.split (get v "Special Features") ", ")]
          (cond [(= damp-val "Control Dot (topside)")
                  (.append (. drum-head has-dampening) (Dampening "CenterDot"))]
                [(= damp-val "Control Dot (underside)")
                 (.append (. drum-head has-dampening) (Dampening "ReverseDot"))]
                [(= damp-val "Control Ring(s)")
                 (.append (. drum-head has-dampening) (Dampening "ControlRing"))]
                [(= damp-val "Removable Dampening")
                 (.append (. drum-head has-dampening) (Dampening "RemovableDampening"))]
                [(= damp-val "Oil Dampening")
                 (.append (. drum-head has-dampening) (Dampening "Oil"))]
                [(= damp-val "Drilled Vent Holes")
                 (.append (. drum-head has-dampening) (Dampening "Holes"))]
                [(= damp-val "Inlay Ring(s)")
                 (.append (. drum-head has-dampening) (Dampening "InlayRing"))]
                [True (f.write f"{k} has additional special feature(s): {damp-val}")]))
         (except [KeyError]
           (f.write f"{k} is missing the 'Special Features' key.\n"))))))

(onto.save "test_ontologies/drums_cymbals.owl")


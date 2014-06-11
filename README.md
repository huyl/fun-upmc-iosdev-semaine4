Exercice «Imagier»
====================

Semaine: 4

Cours: [Programmation sur iPhone et iPad]

[Programmation sur iPhone et iPad]:
https://www.france-universite-numerique-mooc.fr/courses/UPMC/18001/Trimestre_2_2014/about

Établissement: [Université Pierre & Marie Curie](http://www.upmc.fr/)

Plateforme de MOOC: [FUN](https://www.france-universite-numerique-mooc.fr/)

![Screen capture](ImagierScreencap.gif)

Compilation
-----------

Pour compiler:

- Il faut ouvrir le fichier `owned-Imagier.xcworkspace/`, pas
le project `owned-Imagier.xcodeproj/`.
-  Il faut être sûr de bien sélectionner le projet `owned-Imagier` en haut de
   la fenêtre avant de compiler, parce que le défaut c'est de seulement compiler
   ReactiveCocoa (Je sais pas pourquoi).

Techniques
----------

Fonctionnalité :

- ScrollView & ImageView
  - Effet parallaxe
- Calcul mathématique pour la relation entre le pinch et les sliders
- Universelle
- Rotation

Structure :

- Organisation [Model-View-ViewModel
  (MVVM)](http://www.teehanlax.com/blog/model-view-viewmodel-for-ios/)
- Style [Functional Reactive Programming](http://en.wikipedia.org/wiki/Functional_reactive_programming) au travers de ReactiveCocoa
  - Highlight: bidirectional bindings between control value and viewModel
    value, using RACChannelTo
  - Highlight: multiple controls kept in sync (labels, slider, UIImageView, ScrollView zoom)
  - Highlight: signal of signals, although probably not necessary
- L'interface est construise programmatiquement; pas de Storyboard / Interface Builder
- Auto-Layout
- ARC, à cause de ReactiveCocoa et presque [tout le
  monde](http://google-styleguide.googlecode.com/svn/trunk/objcguide.xml?showone=Automatic_Reference_Counting__ARC_#Automatic_Reference_Counting__ARC_) l'utilise.
- Notation pointée (dot notation), parce que c'est idiomatique (comme l'explique
  [Google](http://google-styleguide.googlecode.com/svn/trunk/objcguide.xml?showone=Properties#Properties) et 
  [NY
  Times](https://github.com/NYTimes/objective-c-style-guide#dot-notation-syntax))

Librairies :

- [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) :
pour UI binding et le style Functional Reactive Programming
    - Pour ça, on est obligé à utiliser ARC
- [Masonry](https://github.com/cloudkite/Masonry) :
pour créer facilement les contraintes pour Auto-Layout
- [cocoapods](http://cocoapods.org/) : pour gérer les paquets comme Masonry

# SPDX-License-Identifier: MIT

export SpdxAnnotationV2

#############################################
const SpdxAnnotationV2_NameTable= Table(
         Symbol= [ :Annotator,       :Created,           :Type,                :Comment],
        Mutable= [  true,             true,               true,                 true], 
    Constructor= [  :SpdxCreatorV2,   :SpdxTimeV2,        :string,              :string],
      NameTable= [  :nothing,         :nothing,           :nothing,             :nothing], 
      Multiline= [  false,            false,              true,                 true],
       JSONname= [ "annotator",       "annotationDate",   "annotationType",     "comment"],
   TagValueName= [ "Annotator",       "AnnotationDate",   "AnnotationType",     "AnnotationComment"],
)

Base.@kwdef mutable struct SpdxAnnotationV2 <: AbstractSpdxData
    Annotator::Union{Missing, SpdxCreatorV2}= missing
    Created::Union{Missing, SpdxTimeV2}= missing
    Type::Union{Missing, String}= missing
    Comment::Union{Missing, String}= missing
end

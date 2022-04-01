# SPDX-License-Identifier: MIT

#############################################
const SpdxAnnotationV2_NameTable= Table(
         Symbol= [ :Annotator,       :Created,           :Type,                :Comment],
        Default= [  missing,          missing,            missing,              missing],
        Mutable= [  true,             true,               true,                 true], 
    Constructor= [  SpdxCreatorV2,    SpdxTimeV2,         string,               string],
      NameTable= [  nothing,          nothing,            nothing,              nothing], 
      Multiline= [  false,            false,              true,                 true],
       JSONname= [ "annotator",       "annotationDate",   "annotationType",     "comment"],
   TagValueName= [ "Annotator",       "AnnotationDate",   "AnnotationType",     "AnnotationComment"],
)

struct SpdxAnnotationV2 <: AbstractSpdxData
    MutableFields::OrderedDict{Symbol, Any}
end

function SpdxAnnotationV2()
    MutableFields= init_MutableFields(SpdxAnnotationV2_NameTable)
    return SpdxAnnotationV2(MutableFields)
end

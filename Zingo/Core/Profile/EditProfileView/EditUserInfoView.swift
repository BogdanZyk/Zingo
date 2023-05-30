//
//  EditUserInfoView.swift
//  Zingo
//
//  Created by Bogdan Zykov on 30.05.2023.
//

import SwiftUI

extension EditProfileView{
    struct EditUserInfoView: View {
        @Environment(\.dismiss) private var dismiss
        @State private var text: String = ""
        @ObservedObject var viewModel: EditProfileViewModel
        @State private var selectedGender: User.Gender?
        let type: EditRout
        
        init(viewModel: EditProfileViewModel, type: EditRout){
            self.type = type
            self._viewModel = ObservedObject(initialValue: viewModel)
            setInfo()
        }
        
        private var isGenderType: Bool{
            type.id == 3
        }
        var body: some View {
            VStack{
                if isGenderType{
                    genderPicker
                }else{
                    TextFieldView(placeholder: type.title, text: $text)
                }
                Spacer()
            }
            .padding()
            .background(Color.darkBlack)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(type.title).bold()
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        viewModel.setInfoFromType(type, text: text, gender: selectedGender)
                        dismiss()
                    }
                    .disabled(isGenderType ? false : text.isEmpty)
                }
            }
            .onAppear{
                setInfo()
            }
        }
    }
}

struct EditUserInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EditProfileView.EditUserInfoView(viewModel: EditProfileViewModel(currentUser: User.mock), type: .name("tester"))
        }
    }
}


extension EditProfileView.EditUserInfoView{
    private var genderPicker: some View{
        VStack(alignment: .leading, spacing: 16){
            ForEach(User.Gender.allCases, id: \.self) { type in
                HStack{
                    Image(systemName: selectedGender == type ?  "checkmark.circle.fill" : "circle")
                        .foregroundColor(.accentColor)
                    Text(type.rawValue.capitalized)
                }
                .font(.title3)
                .onTapGesture {
                    selectedGender = type
                }
            }
        }
        .foregroundColor(.white)
        .hLeading()
    }
    
    private func setInfo(){
        switch type{
            
        case .name(let name):
            text = name.orEmpty
        case .username(let username):
            text = username.orEmpty
        case .bio(let bio):
            text = bio.orEmpty
        case .gender(let gender):
            selectedGender = gender
        }
    }
}

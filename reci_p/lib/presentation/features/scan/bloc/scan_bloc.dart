import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reci_p/domain/repositories/recipe_repository.dart';
import 'package:reci_p/presentation/features/scan/bloc/scan_event.dart';
import 'package:reci_p/presentation/features/scan/bloc/scan_state.dart';
import 'package:reci_p/presentation/features/recipe_list/bloc/recipe_list_bloc.dart';
import 'package:reci_p/presentation/features/recipe_list/bloc/recipe_list_event.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final RecipeRepository recipeRepository;
  final ImagePicker _picker = ImagePicker();
  RecipeListBloc? recipeListBloc;

  ScanBloc({required this.recipeRepository}) : super(ScanInitial()) {
    on<ScanImageFromCamera>(_onScanImageFromCamera);
    on<ScanImageFromGallery>(_onScanImageFromGallery);
    on<ClearScanResults>(_onClearScanResults);
    on<AppStarted>(_onAppStarted);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<ScanState> emit) async {
    emit(ScanInitial());
  }

  Future<void> _onScanImageFromCamera(
      ScanImageFromCamera event, Emitter<ScanState> emit) async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        emit(ScanLoading());
        final imagePath = pickedFile.path;
        emit(ScanSuccess(imagePath: imagePath));
        recipeListBloc?.add(FetchRecipes(ingredients: [imagePath]));
      } else {
        emit(ScanInitial());
      }
    } catch (e) {
      emit(ScanFailure(error: e.toString()));
    }
  }

  Future<void> _onScanImageFromGallery(
      ScanImageFromGallery event, Emitter<ScanState> emit) async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        emit(ScanLoading());
        final imagePath = pickedFile.path;
        emit(ScanSuccess(imagePath: imagePath));
        recipeListBloc?.add(FetchRecipes(ingredients: [imagePath]));
      } else {
        emit(ScanInitial());
      }
    } catch (e) {
      emit(ScanFailure(error: e.toString()));
    }
  }

  Future<void> _onClearScanResults(
      ClearScanResults event, Emitter<ScanState> emit) async {
    emit(ScanInitial());
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
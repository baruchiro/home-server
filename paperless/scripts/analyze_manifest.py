import json
from collections import defaultdict
from pathlib import Path
import sys
import shutil
from datetime import datetime

def load_manifest(manifest_path):
    """Load and parse the manifest file."""
    try:
        with open(manifest_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except json.JSONDecodeError as e:
        print(f"Error parsing manifest file: {e}")
        sys.exit(1)
    except FileNotFoundError:
        print(f"Manifest file not found: {manifest_path}")
        sys.exit(1)

def analyze_manifest(manifest_data):
    """Group manifest elements by model and analyze them."""
    model_groups = defaultdict(list)
    
    # Group elements by model
    for item in manifest_data:
        if isinstance(item, dict) and 'model' in item:
            model_groups[item['model']].append(item)
    
    # Print analysis
    print("\nManifest Analysis:")
    print("=" * 50)
    
    for model, items in sorted(model_groups.items()):
        print(f"\nModel: {model}")
        print(f"Count: {len(items)}")
        
        # Show sample fields from first item if available
        if items:
            print("Fields present:")
            for field_name in items[0]['fields'].keys():
                print(f"  - {field_name}")
    
    return model_groups

def deduplicate_documents(manifest_data):
    """Remove duplicate documents, keeping only the most recent version."""
    # Group documents by PK
    doc_groups = defaultdict(list)
    non_doc_items = []
    
    for item in manifest_data:
        if item.get('model') == 'documents.document':
            doc_groups[item['pk']].append(item)
        else:
            non_doc_items.append(item)
    
    # Find duplicates and keep only the most recent version
    duplicates_found = False
    kept_docs = []
    
    for pk, docs in doc_groups.items():
        if len(docs) > 1:
            duplicates_found = True
            print(f"\nFound {len(docs)} versions of document {pk}")
            # Sort by modified date and keep the most recent
            most_recent = sorted(docs, key=lambda x: x['fields']['modified'])[-1]
            kept_docs.append(most_recent)
            print(f"Keeping version modified at: {most_recent['fields']['modified']}")
            print(f"Title: {most_recent['fields']['title']}")
        else:
            kept_docs.append(docs[0])
    
    if duplicates_found:
        print("\nDuplicate documents summary:")
        print(f"- Original document count: {sum(len(docs) for docs in doc_groups.values())}")
        print(f"- Final document count: {len(kept_docs)}")
    
    # Combine non-document items with kept documents
    return non_doc_items + kept_docs

def find_missing_references(model_groups):
    """Find all missing correspondent and tag references."""
    valid_ids = {
        'tags': {item['pk'] for item in model_groups.get('documents.tag', [])},
        'correspondents': {item['pk'] for item in model_groups.get('documents.correspondent', [])}
    }
    
    missing_refs = {
        'tags': set(),
        'correspondents': set()
    }
    
    # Check documents for missing references
    for doc in model_groups.get('documents.document', []):
        fields = doc['fields']
        
        # Check correspondent
        if fields.get('correspondent') and fields['correspondent'] not in valid_ids['correspondents']:
            missing_refs['correspondents'].add(fields['correspondent'])
        
        # Check tags
        for tag_id in fields.get('tags', []):
            if tag_id not in valid_ids['tags']:
                missing_refs['tags'].add(tag_id)
    
    return missing_refs

def create_missing_items(manifest_data, missing_refs):
    """Create placeholder items for missing correspondents and tags."""
    # Create missing correspondents
    for corr_id in missing_refs['correspondents']:
        manifest_data.append({
            "model": "documents.correspondent",
            "pk": corr_id,
            "fields": {
                "owner": None,
                "name": f"MISSING-{corr_id}",
                "match": "",
                "matching_algorithm": 1,
                "is_insensitive": True
            }
        })
    
    # Create missing tags
    for tag_id in missing_refs['tags']:
        manifest_data.append({
            "model": "documents.tag",
            "pk": tag_id,
            "fields": {
                "owner": None,
                "name": f"MISSING-{tag_id}",
                "match": "",
                "matching_algorithm": 1,
                "is_insensitive": True,
                "color": "#ff0000",
                "is_inbox_tag": False
            }
        })
    
    if missing_refs['correspondents'] or missing_refs['tags']:
        print("\nCreated placeholder items:")
        if missing_refs['correspondents']:
            print(f"- Created {len(missing_refs['correspondents'])} missing correspondents")
            for corr_id in sorted(missing_refs['correspondents']):
                print(f"  * Correspondent ID {corr_id}: MISSING-{corr_id}")
        if missing_refs['tags']:
            print(f"- Created {len(missing_refs['tags'])} missing tags")
            for tag_id in sorted(missing_refs['tags']):
                print(f"  * Tag ID {tag_id}: MISSING-{tag_id}")
    
    return manifest_data

def validate_relationships(model_groups):
    """Validate relationships between documents and related entities."""
    # Get all valid IDs for each model
    valid_ids = {
        'tags': {item['pk'] for item in model_groups.get('documents.tag', [])},
        'correspondents': {item['pk'] for item in model_groups.get('documents.correspondent', [])},
        'document_types': {item['pk'] for item in model_groups.get('documents.documenttype', [])},
        'users': {item['pk'] for item in model_groups.get('auth.user', [])},
        'documents': {item['pk'] for item in model_groups.get('documents.document', [])}
    }
    
    issues = []
    
    # Check documents
    for doc in model_groups.get('documents.document', []):
        doc_id = doc['pk']
        fields = doc['fields']
        
        # Check document type
        if fields.get('document_type') and fields['document_type'] not in valid_ids['document_types']:
            issues.append(f"Document {doc_id}: References non-existent document type {fields['document_type']}")
        
        # Check owner
        if fields.get('owner') and fields['owner'] not in valid_ids['users']:
            issues.append(f"Document {doc_id}: References non-existent owner {fields['owner']}")
    
    # Check notes
    for note in model_groups.get('documents.note', []):
        note_id = note['pk']
        fields = note['fields']
        
        # Check document reference
        if fields.get('document') and fields['document'] not in valid_ids['documents']:
            issues.append(f"Note {note_id}: References non-existent document {fields['document']}")
        
        # Check user reference
        if fields.get('user') and fields['user'] not in valid_ids['users']:
            issues.append(f"Note {note_id}: References non-existent user {fields['user']}")
    
    # Check custom field instances
    for cfi in model_groups.get('documents.customfieldinstance', []):
        cfi_id = cfi['pk']
        fields = cfi['fields']
        
        # Check document reference
        if fields.get('document') and fields['document'] not in valid_ids['documents']:
            issues.append(f"CustomFieldInstance {cfi_id}: References non-existent document {fields['document']}")
    
    return issues

def load_all_manifests(export_dir):
    """Load main manifest and all individual document manifests."""
    all_items = []
    
    # Load main manifest
    main_manifest_path = Path(export_dir) / "manifest.json"
    if main_manifest_path.exists():
        all_items.extend(load_manifest(main_manifest_path))
    
    # Load individual document manifests
    json_dir = Path(export_dir) / "json"
    if json_dir.exists() and json_dir.is_dir():
        for manifest_file in json_dir.glob("*-manifest.json"):
            all_items.extend(load_manifest(manifest_file))
    
    return all_items

def clean_manifest(manifest_data):
    """Remove audit logs and return cleaned data."""
    return [item for item in manifest_data if item.get('model') != 'auditlog.logentry']

def save_manifest(manifest_data, export_dir):
    """Save the cleaned manifest data and backup the original."""
    manifest_path = Path(export_dir) / "manifest.json"
    
    # Backup original manifest if it exists
    if manifest_path.exists():
        backup_name = f"manifest.bak.{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        backup_path = manifest_path.parent / backup_name
        shutil.copy2(manifest_path, backup_path)
        print(f"\nOriginal manifest backed up to: {backup_path}")
    
    # Save cleaned manifest
    with open(manifest_path, 'w', encoding='utf-8') as f:
        json.dump(manifest_data, f, indent=2, ensure_ascii=False)
    print(f"Cleaned manifest saved to: {manifest_path}")

def main():
    if len(sys.argv) != 2:
        print("Usage: python analyze_manifest.py <export_directory>")
        sys.exit(1)
    
    export_dir = sys.argv[1]
    print(f"Analyzing manifests in: {export_dir}")
    
    # Load and analyze original data
    manifest_data = load_all_manifests(export_dir)
    print(f"\nTotal items loaded: {len(manifest_data)}")
    
    # Step 1: Remove audit logs
    print("\nRemoving audit logs...")
    manifest_data = clean_manifest(manifest_data)
    print(f"Items remaining after audit log removal: {len(manifest_data)}")
    
    # Step 2: Remove duplicate documents
    print("\nChecking for duplicate documents...")
    manifest_data = deduplicate_documents(manifest_data)
    
    # Step 3: Group and analyze remaining items
    model_groups = analyze_manifest(manifest_data)
    
    # Step 4: Find and create missing references
    missing_refs = find_missing_references(model_groups)
    if missing_refs['correspondents'] or missing_refs['tags']:
        manifest_data = create_missing_items(manifest_data, missing_refs)
        # Re-analyze after adding missing items
        model_groups = analyze_manifest(manifest_data)
    
    # Step 5: Final validation
    issues = validate_relationships(model_groups)
    if issues:
        print("\nFound relationship issues:")
        for issue in issues:
            print(f"- {issue}")
        
        response = input("\nIssues found. Do you want to save the manifest anyway? (y/n): ")
        if response.lower() != 'y':
            print("Aborting without saving.")
            return
    
    # Save the cleaned manifest
    save_manifest(manifest_data, export_dir)

if __name__ == "__main__":
    main() 